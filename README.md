# Auto Subdomain Hunter 🔍

<p align="center">
  <img src="https://img.shields.io/badge/Version-2.0-brightgreen" alt="Version">
  <img src="https://img.shields.io/badge/Kali-Linux-blue" alt="Kali Linux">
  <img src="https://img.shields.io/badge/License-MIT-yellow" alt="License">
  <img src="https://img.shields.io/badge/PRs-welcome-orange" alt="PRs Welcome">
  <img src="https://img.shields.io/github/stars/hash-089/auto-subdomain-hunter?style=social" alt="Stars">
</p>

<p align="center">
  <b>Complete automated subdomain enumeration and live host checking tool for Kali Linux</b><br>
  <b>Zero configuration needed - Installs everything automatically!</b>
</p>

---

## 📋 Description

**Auto Subdomain Hunter** is a powerful bash script designed for Kali Linux that automates the entire process of subdomain enumeration and live host checking. Unlike other tools that require manual installation of dependencies, this script **installs everything automatically** on first run. It combines multiple industry-standard tools to provide comprehensive results, checks which subdomains are actually live, and generates detailed reports in multiple formats.

Whether you're a bug bounty hunter, penetration tester, or security researcher, this tool saves hours of manual work by automating the reconnaissance phase completely.

---

## ✨ Features

| Feature | Description |
|---------|-------------|
| 🔄 **Auto-Install** | Installs all dependencies automatically on first run |
| 🛠️ **Multi-Tool** | Uses 6+ tools: assetfinder, subfinder, findomain, sublist3r, amass, httpx |
| 🌐 **Live Checking** | Identifies active subdomains with HTTP status codes, titles, and server info |
| 📊 **Rich Reports** | Generates TXT, JSON, and CSV reports automatically |
| 🎯 **Zero Config** | Just run it - works on fresh Kali installations |
| ⚡ **Fast** | Multi-threaded live checking with 100 concurrent threads |
| 📁 **Organized** | Structured output with separate folders for raw data, processed results, and logs |
| 🔧 **Fallback Methods** | Continues working even if some tools fail to install |
| 🚨 **Error Handling** | Comprehensive error logging and graceful failure handling |
| 📈 **Progress Tracking** | Real-time progress indicators for all phases |

---

## 🚀 Quick Start

```bash
# One command does everything
git clone https://github.com/hash-089/auto-subdomain-hunter.git
cd auto-subdomain-hunter
chmod +x auto_subdomain_hunter.sh
./auto_subdomain_hunter.sh example.com
```

That's it! The script will automatically install all dependencies and start scanning.

---

## 📦 Installation

### Method 1: Clone Repository (Recommended)

```bash
# Clone the repository
git clone https://github.com/hash-089/auto-subdomain-hunter.git

# Navigate to directory
cd auto-subdomain-hunter

# Make script executable
chmod +x auto_subdomain_hunter.sh

# Run it (installs everything automatically!)
./auto_subdomain_hunter.sh example.com
```

### Method 2: Direct Download

```bash
# Download the script
wget https://raw.githubusercontent.com/hash-089/auto-subdomain-hunter/main/auto_subdomain_hunter.sh

# Make it executable
chmod +x auto_subdomain_hunter.sh

# Run it
./auto_subdomain_hunter.sh example.com
```

### Method 3: One-Line Install

```bash
curl -s https://raw.githubusercontent.com/hash-089/auto-subdomain-hunter/main/install.sh | bash
```

---

## 🎯 Usage

### Basic Commands

```bash
# Basic scan
./auto_subdomain_hunter.sh example.com

# Scan with custom output directory
./auto_subdomain_hunter.sh example.com ./my_results

# Show help
./auto_subdomain_hunter.sh -h
```

### Advanced Examples

```bash
# Scan multiple domains from a file
for domain in $(cat domains.txt); do
    ./auto_subdomain_hunter.sh $domain
done

# Background scan for large domains
nohup ./auto_subdomain_hunter.sh largecompany.com > scan.log 2>&1 &

# Scan and email results
./auto_subdomain_hunter.sh example.com && \
mail -s "Scan Results for example.com" youremail@domain.com < $(ls -d example.com_*/)/final_report.txt

# Quick statistics after scan
cd example.com_*/
echo "Live hosts: $(cat processed/live_subs.txt | wc -l)"
echo "HTTP 200: $(grep -c "200" processed/live_with_http.txt)"
```

---

## 📁 Output Structure

After running, you'll get an organized directory like this:

```
example.com_20240101_120000/
├── raw/
│   └── all_subs.txt          # Raw results from all tools combined
├── processed/
│   ├── unique_subs.txt       # Unique subdomains after deduplication
│   ├── live_subs.txt         # Just the live host URLs
│   └── live_with_http.txt    # Live hosts with HTTP status, title, server
├── logs/
│   └── error.log             # Error logs for troubleshooting
├── final_report.txt          # Detailed human-readable report
├── results.json              # JSON format for automation
└── results.csv               # CSV format for spreadsheets
```

---

## 📊 Sample Output

```
╔════════════════════════════════════════════════════════════╗
║                    AUTO SUBDOMAIN HUNTER                   ║
║                         Version 2.0                         ║
║              Complete Automated Solution for Kali           ║
╚════════════════════════════════════════════════════════════╝

[+] Phase 1: Installing all required tools...
[*] Installing Go...
[*] Installing Python and pip...
[*] Installing main tools from Kali repositories...
  [✓] findomain installed
  [✓] assetfinder installed
  [✓] subfinder installed
  [✓] httpx-toolkit installed

[+] Phase 2: Subdomain enumeration...
[*] Running assetfinder... [✓]
[*] Running subfinder... [✓]
[*] Running findomain... [✓]
[*] Running sublist3r... [✓]
[*] Running amass... [✓]
[+] Total unique subdomains found: 157

[+] Phase 3: Live subdomain checking...
[*] Probing subdomains with httpx-toolkit (100 threads)...
[✓] Found 43 live subdomains

[+] Preview (first 10 live subdomains):
  http://mail.example.com [200] [Mail Server] [nginx]
  https://blog.example.com [200] [WordPress] [Apache]
  https://api.example.com [401] [Unauthorized] [nginx]
  http://dev.example.com [403] [Forbidden] [Apache]
  https://admin.example.com [200] [Login Page] [nginx]

[+] Phase 4: Generating reports...
[✓] Report saved to: example.com_20240101_120000/final_report.txt
[✓] JSON saved: results.json
[✓] CSV saved: results.csv

════════════════════════════════════════════════════════════
                    SCAN COMPLETE!                          
════════════════════════════════════════════════════════════
  Workspace:      example.com_20240101_120000
  Total unique:   157
  Live hosts:     43
  Report:         example.com_20240101_120000/final_report.txt
  JSON:           example.com_20240101_120000/results.json
  CSV:            example.com_20240101_120000/results.csv
════════════════════════════════════════════════════════════
```

---

## 🛠️ Tools Used

The script automatically installs and uses these industry-standard tools:

| Tool | Purpose | GitHub |
|------|---------|--------|
| **assetfinder** | Subdomain discovery | [tomnomnom/assetfinder](https://github.com/tomnomnom/assetfinder) |
| **subfinder** | Passive subdomain enumeration | [projectdiscovery/subfinder](https://github.com/projectdiscovery/subfinder) |
| **findomain** | Fast subdomain discovery | [Findomain/Findomain](https://github.com/Findomain/Findomain) |
| **sublist3r** | Python-based enumeration | [aboul3la/Sublist3r](https://github.com/aboul3la/Sublist3r) |
| **amass** | In-depth enumeration | [OWASP/Amass](https://github.com/OWASP/Amass) |
| **httpx** | Live host checking | [projectdiscovery/httpx](https://github.com/projectdiscovery/httpx) |
| **anew** | Deduplication | [tomnomnom/anew](https://github.com/tomnomnom/anew) |

---

## 💻 Requirements

- **Operating System:** Kali Linux (or any Debian-based Linux distribution)
- **Permissions:** Sudo access (for automatic installations)
- **Internet:** Required for installation and scanning
- **Storage:** ~500MB free space for tools
- **Memory:** 1GB+ RAM recommended
- **Time:** Varies based on domain size (usually 2-10 minutes)

---

## ⚙️ Configuration

### Adding API Keys (For Better Results)

For enhanced results, you can add API keys to configuration files:

```bash
# For subfinder
nano ~/.config/subfinder/config.yaml
# Add your API keys for: SecurityTrails, Censys, Shodan, etc.

# For findomain
nano ~/.config/findomain/findomain.conf
# Add your API keys for: SecurityTrails, Virustotal, etc.
```

### Sample API Configuration

```yaml
# ~/.config/subfinder/config.yaml
securitytrails: ["your-api-key"]
shodan: ["your-api-key"]
censys: ["your-api-key"]
virustotal: ["your-api-key"]
```

---

## 🔧 Troubleshooting

### Common Issues and Solutions

| Issue | Solution |
|-------|----------|
| **Tools not installing** | Run `sudo apt update` manually first |
| **No subdomains found** | Domain might be small; try with API keys |
| **Permission denied** | Run `chmod +x auto_subdomain_hunter.sh` |
| **Slow scan** | Reduce thread count in the script |
| **HTTP errors** | Check internet connection |

### Check Error Logs

```bash
# View error logs
cat example.com_*/logs/error.log

# Real-time monitoring during scan
tail -f example.com_*/logs/error.log
```

---

## 🤝 Contributing

Contributions are welcome and appreciated! Here's how you can help:

1. **Fork** the repository
2. **Create** a feature branch (`git checkout -b feature/AmazingFeature`)
3. **Commit** your changes (`git commit -m 'Add AmazingFeature'`)
4. **Push** to the branch (`git push origin feature/AmazingFeature`)
5. **Open** a Pull Request

### Contribution Ideas
- Add more subdomain discovery tools
- Improve speed optimizations
- Add new output formats
- Fix bugs and issues
- Improve documentation
- Add Docker support

---

## 📝 Changelog

### Version 2.0 (Current)
- ✅ Auto-installation of all dependencies
- ✅ JSON and CSV output formats
- ✅ Multi-threaded live checking (100 threads)
- ✅ Progress indicators for each phase
- ✅ Better error handling and logging
- ✅ Fallback methods when tools are missing
- ✅ Improved output directory structure

### Version 1.0
- ✅ Basic subdomain enumeration
- ✅ Live host checking
- ✅ Text report generation

---

## 🐛 Known Issues

- Some tools may fail to install on non-Kali systems
- Rate limiting may affect results on very large domains
- API keys required for optimal results
- First run takes longer due to installations

---

## 📜 License

Distributed under the MIT License. See `LICENSE` for more information.

```
MIT License

Copyright (c) 2024 hash-089

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files...
```

---

## 🙏 Acknowledgments

- **TomNomNom** ([@tomnomnom](https://github.com/tomnomnom)) for assetfinder and anew
- **ProjectDiscovery** ([@projectdiscovery](https://github.com/projectdiscovery)) for subfinder and httpx
- **OWASP** for Amass
- **aboul3la** for Sublist3r
- **Findomain** team for their amazing tool
- The entire InfoSec community for inspiration

---

## 📞 Contact

**GitHub:** [hash-089](https://github.com/hash-089)

**Project Link:** [https://github.com/hash-089/auto-subdomain-hunter](https://github.com/hash-089/auto-subdomain-hunter)

**Report Issues:** [https://github.com/hash-089/auto-subdomain-hunter/issues](https://github.com/hash-089/auto-subdomain-hunter/issues)

---

## ⭐ Support

If you find this tool useful, please consider:

- Giving it a **star** on GitHub ⭐
- Sharing it with fellow security researchers
- Contributing to the project
- Reporting bugs and suggesting features

---

## 🔗 Related Projects

- [Nuclei](https://github.com/projectdiscovery/nuclei) - Vulnerability scanner
- [Waybackurls](https://github.com/tomnomnom/waybackurls) - Historical URL fetching
- [FFuF](https://github.com/ffuf/ffuf) - Web fuzzing
- [Aquatone](https://github.com/michenriksen/aquatone) - Visual inspection

---

<p align="center">
  <b>Made with ❤️ for the Kali Linux Community</b><br>
  <i>Happy Hunting! 🏴‍☠️</i>
</p>

<p align="center">
  <img src="https://img.shields.io/github/last-commit/hash-089/auto-subdomain-hunter" alt="Last Commit">
  <img src="https://img.shields.io/github/issues/hash-089/auto-subdomain-hunter" alt="Issues">
  <img src="https://img.shields.io/github/forks/hash-089/auto-subdomain-hunter" alt="Forks">
</p>
