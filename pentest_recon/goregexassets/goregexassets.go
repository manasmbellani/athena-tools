// Golang tool to extract asssets such as domains, emails, IPs from single file,
// folder OR list of files and writes to the specific output file
package main

import (
	"flag"
	"fmt"
	"io/ioutil"
	"log"
	"os"
	"path/filepath"
	"regexp"
	"strings"
	"sync"
)

// AllowedAssetTypes - List of asset types that this script can search for
var AllowedAssetTypes []string = []string{"email", "ip", "domain"}

// Find takes a slice and looks for an element in it. If found it will
// return it's key, otherwise it will return -1 and a bool of false.
func Find(slice []string, val string) (int, bool) {
	for i, item := range slice {
		if item == val {
			return i, true
		}
	}
	return -1, false
}

// Regex patterns for IP, domains and email addresses
const RegexIP = "[0-9]{1,3}\\.[0-9]{1,3}\\.[0-9]{1,3}\\.[0-9]{1,3}"
const RegexDomain = "([a-zA-Z0-9_-]+\\.)+[a-zA-Z0-9_-]{1,6}"
const RegexEmail = "[a-zA-Z0-9_-]+@([a-zA-Z0-9_-]+\\.)+[a-zA-Z0-9]{1,6}"

func main() {
	pathsToParse := flag.String("paths", "",
		"files/folder paths from which to extract assets")
	assetType := flag.String("assetType", "",
		"AssetType to extract. Can be one of: "+strings.Join(AllowedAssetTypes, ","))
	flag.Parse()

	if *pathsToParse == "" {
		log.Fatalln("[-] Files for assets to parse must be provided.")
	}

	// Check if valid asset type provided
	isValidAssetType := false
	for _, iAssetType := range AllowedAssetTypes {
		if *assetType == iAssetType {
			isValidAssetType = true
			break
		}
	}
	if !isValidAssetType {
		log.Fatalf("[-] Invalid asset type: %s provided. Can be one of: %s",
			*assetType, strings.Join(AllowedAssetTypes, ","))
	}

	// Convert the comma-sep list of files, folders to loop through
	pathsToCheck := strings.Split(*pathsToParse, ",")

	// List of all files in the folders/files above
	var filesToParse []string

	// Loop through each path and attempt to discover all files
	for _, pathToCheck := range pathsToCheck {

		//Check if paths exist
		fi, err := os.Stat(pathToCheck)
		if err != nil {
			fmt.Fprintf(os.Stderr, "[-] Path: %s not found\n", pathToCheck)
		} else {

			// Check if we are dealing with a file/folder
			switch mode := fi.Mode(); {

			// Get all files from the folder recursively - harder case
			case mode.IsDir():

				filepath.Walk(pathToCheck,
					func(path string, f os.FileInfo, err error) error {

						// Determine if the path is actually a file
						fi, err := os.Stat(path)
						if fi.Mode().IsRegular() == true {

							// Add the path if it doesn't already exist to list
							// of all files
							_, found := Find(filesToParse, path)
							if !found {
								filesToParse = append(filesToParse, path)
							}
						}
						return nil
					})

			// Add a single file, if not already present - easier case
			case mode.IsRegular():

				// Add the path if it doesn't already exist to list
				// of all files
				_, found := Find(filesToParse, pathToCheck)
				if !found {
					filesToParse = append(filesToParse, pathToCheck)
				}
			}
		}
	}

	// List of all emails, domains, IPs
	var emails []string
	var domains []string
	var ips []string

	// Define locks for each slice to ensure that goroutines don't run over each
	// other and not give unique output
	var emailsMutex sync.Mutex
	var domainsMutex sync.Mutex
	var ipsMutex sync.Mutex

	var wg sync.WaitGroup

	// Start look through each file path now, and add assets if not found
	for _, filepath := range filesToParse {

		if filepath != "" {
			wg.Add(1)
			go func(filepath string) {
				defer wg.Done()

				// Read the file contents
				bincontent, err := ioutil.ReadFile(filepath)
				if err != nil {
					log.Fatalf("[-] Cannot read file: %s. Error: %s\n", filepath,
						err.Error())
				}
				fileContent := string(bincontent)

				// Cannot read a file: stop script since something is wrong...
				if err != nil {
					log.Fatalf("[-] Can't read file: %s\n", filepath)
				}

				// Get all emails from a file
				if *assetType == "all" || *assetType == "email" {
					regexEmail, _ := regexp.Compile(RegexEmail)
					emailsInFile := regexEmail.FindAllString(fileContent, -1)
					for _, email := range emailsInFile {

						// Only build a list of unique emails
						prevFound := false
						emailsMutex.Lock()
						for _, iEmail := range emails {
							if email == iEmail {
								prevFound = true
								break
							}
						}
						if !prevFound {
							emails = append(emails, email)
							fmt.Println(email)
						}
						emailsMutex.Unlock()
					}
				}

				// Read all IPs from a file
				if *assetType == "all" || *assetType == "ip" {
					regexIP, _ := regexp.Compile(RegexIP)
					ipsInFile := regexIP.FindAllString(fileContent, -1)
					for _, ip := range ipsInFile {

						// Only build a list of unique IPs
						prevFound := false
						ipsMutex.Lock()
						for _, iIP := range ips {
							if ip == iIP {
								prevFound = true
								break
							}
						}
						if !prevFound {

							ips = append(ips, ip)
							fmt.Println(ip)
						}
						ipsMutex.Unlock()
					}
				}

				// Read all domains from file
				if *assetType == "all" || *assetType == "domain" {
					regexDomain, _ := regexp.Compile(RegexDomain)
					domainsInFile := regexDomain.FindAllString(fileContent, -1)

					regexIP, _ := regexp.Compile(RegexIP)
					ipsInFile := regexIP.FindAllString(fileContent, -1)

					for _, domain := range domainsInFile {
						isIP := false
						for _, ip := range ipsInFile {
							if ip == domain {
								isIP = true
								break
							}
						}

						if !isIP {

							// Only build a list of unique domains
							prevFound := false
							domainsMutex.Lock()
							for _, iDomain := range domains {
								if domain == iDomain {
									prevFound = true
									break
								}
							}
							if !prevFound {
								domains = append(domains, domain)
								fmt.Println(domain)
							}
							domainsMutex.Unlock()
						}
					}
				}

			}(filepath)
		}
	}

	wg.Wait()

}
