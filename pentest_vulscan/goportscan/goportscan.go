// Script is used to run a portscan via nmap (assumed accessible via $PATH var),
// and identify different protocols on host/ip addresses listing
package main

import (
	"bufio"
	"flag"
	"fmt"
	"io/ioutil"
	"log"
	"os"
	"os/exec"
	"path"
	"regexp"
	"strings"
	"sync"

	"gopkg.in/yaml.v2"
)

// OpenPortLineSig - Regex for identifying line containing an open port in Nmap Output
const OpenPortLineSig = "[0-9]+/(tcp|udp).*open[\\s]+"

// Execute a command to get the output, error
func execCmd(cmdToExec string, verbose bool) string {

	if verbose {
		log.Printf("[v] Executing cmd: %s\n", cmdToExec)
	}

	args := strings.Fields(cmdToExec)
	cmd := exec.Command(args[0], args[1:]...)
	out, err := cmd.CombinedOutput()
	var outStr, errStr string
	if out == nil {
		outStr = ""
	} else {
		//log.Printf("Command Output:%s\n", out)
		outStr = string(out)
	}

	if err == nil {
		errStr = ""
	} else {
		errStr = string(err.Error())
		//log.Printf("Command Error: %s\n", err)
	}

	totalOut := (outStr + "\n" + errStr)
	if verbose {
		log.Printf("[v] Output of cmd '%s':\n%s\n", cmdToExec, totalOut)
	}

	return totalOut
}

type YamlSignatureConfig struct {
	Signatures []struct {
		Protocol string `yaml:"protocol"`
		Regex    string `yaml:"regex"`
	} `yaml:"signatures"`
}

func main() {
	portStrPtr := flag.String("ports", "common", "TCP ports to scan for - "+
		"can specify individual ports separated with comma (,)")
	outprefixfolderPtr := flag.String("o", "",
		"Output folder's prefix to write nmap results. Contains 'hostname'"+
			"too as suffix")
	runVersionScansPtr := flag.Bool("runVersionScan", false,
		"Include version scans for TCP traffic")
	verbosePtr := flag.Bool("verbose", false, "Show detailed info as cmds exec")
	skipUDPPtr := flag.Bool("skipUDP", false, "Skip UDP scanning of host")

	signaturesFilePtr := flag.String("sigFile", "signatures.yaml",
		"Signatures file to identify protocol signatures")
	flag.Parse()

	portsStr := *portStrPtr
	verbose := *verbosePtr
	sigFile := *signaturesFilePtr
	skipUDP := *skipUDPPtr
	outprefixfolder := *outprefixfolderPtr
	runVersionScans := *runVersionScansPtr

	// Get the ports to scan
	portsArg := ""
	if portsStr == "all" {
		portsArg = "--top-ports 65536"
	} else if portsStr == "common" {
		portsArg = "--top-ports 1000"
	} else {
		portsArg = "-p " + portsStr
	}

	// Parse the signatures file and get the signatures
	var c YamlSignatureConfig
	yamlFile, err := ioutil.ReadFile(sigFile)
	if err != nil {
		log.Fatalf("[-] yamlFile.Get err   #%v ", err)
	}
	err = yaml.Unmarshal(yamlFile, &c)
	if err != nil {
		log.Fatalf("[-] Unmarshal Error: %v", err)
	}
	signatures := c.Signatures

	var wg sync.WaitGroup

	// Take list of hosts to scan from user via STDIN
	sc := bufio.NewScanner(os.Stdin)
	for sc.Scan() {
		host := sc.Text()

		wg.Add(1)
		go func() {

			// Prepare outfiles to write nmap results in different formats for
			// TCP/UDP
			outfolder := ""
			outfileNormTCP := ""
			outfileGrepTCP := ""
			outfileXmlTCP := ""
			outfileNormUDP := ""
			outfileGrepUDP := ""
			outfileXmlUDP := ""
			if outprefixfolder != "" {
				outfolder = outprefixfolder + "-" + host

				// Make the output folder if it doesn't exist
				_ = os.Mkdir(outfolder, 0700)

				outfileNormTCP = path.Join(outfolder, "out-nmap-norm-tcp.txt")
				outfileGrepTCP = path.Join(outfolder, "out-nmap-grep-tcp.txt")
				outfileXmlTCP = path.Join(outfolder, "out-nmap-xml-tcp.txt")

				outfileNormUDP = path.Join(outfolder, "out-nmap-norm-udp.txt")
				outfileGrepUDP = path.Join(outfolder, "out-nmap-grep-udp.txt")
				outfileXmlUDP = path.Join(outfolder, "out-nmap-xml-udp.txt")
			}

			// Run TCP Port scan
			cmd := ""
			cmd = "sudo nmap --open {portsArg} -sS -Pn {host}"
			if outfolder != "" {
				cmd += " -oN " + outfileNormTCP + " -oG " + outfileGrepTCP +
					" -oX " + outfileXmlTCP
			}
			if runVersionScans {
				cmd += " -sV"
			}
			cmd = strings.ReplaceAll(cmd, "{portsArg}", portsArg)
			cmd = strings.ReplaceAll(cmd, "{host}", host)
			outTCP := execCmd(cmd, verbose)

			// Run UDP Port scan
			outUDP := ""
			if !skipUDP {
				cmd = "sudo nmap --open --top-ports 20 -sU -Pn {host}"
				if outfolder != "" {
					cmd += " -oN " + outfileNormUDP + " -oG " + outfileGrepUDP +
						" -oX " + outfileXmlUDP
				}
				cmd = strings.ReplaceAll(cmd, "{portsArg}", portsArg)
				cmd = strings.ReplaceAll(cmd, "{host}", host)
				outUDP = execCmd(cmd, verbose)
			}

			// Combine outputs
			out := outTCP + "\n" + outUDP

			// Parse output to look for lines with open ports
			outlines := strings.Split(out, "\n")
			for _, outline := range outlines {
				if outline != "" {

					// Find a line with open port
					openPortLineRegex := OpenPortLineSig
					found, _ := regexp.MatchString(openPortLineRegex, outline)
					if found {
						// Get the port
						port := strings.Split(outline, "/")[0]

						// Is port on TCP/UDP?
						transportProtocol := strings.Split(strings.Split(outline, "/")[1], " ")[0]

						// Track if signature found for port
						sigFound := false

						// Search for a signature within the output
						for _, signature := range signatures {

							// Check if relevant regex signature present in nmap
							// outline - if it is, then implement the block
							protocolRegex := signature.Regex
							protocol := signature.Protocol

							found, _ := regexp.MatchString(protocolRegex, outline)
							if found {
								fmt.Printf("[%s] %s://%s:%s\n", transportProtocol, protocol, host, port)
								sigFound = true
								break
							}
						}
						if !sigFound {
							fmt.Printf("[%s] unknown://%s:%s\n", transportProtocol, host, port)
						}
					}
				}
			}

			wg.Done()
		}()
	}
	wg.Wait()
}
