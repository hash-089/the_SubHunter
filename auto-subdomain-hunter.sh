#!/bin/bash

# Auto Subdomain Hunter v2.0 - VERBOSE EDITION
# Shows EVERYTHING that's happening

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m'

# Print with timestamp
log() {
    echo -e "[$(date +%H:%M:%S)] ${2}${1}${NC}"
}

print_color() {
    echo -e "${2}${1}${NC}"
}

print_banner() {
    clear
    echo -e "${BLUE}"
    echo "╔════════════════════════════════════════════════════════════╗"
    echo "║                    AUTO SUBDOMAIN HUNTER                   ║"
    echo "║                         Version 2.0                         ║"
    echo "║                      VERBOSE EDITION                        ║"
    echo "║              Showing EVERY step in detail                   ║"
    echo "╚════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
    echo ""
}

check_internet() {
    log "[*] Checking internet connectivity..." "$YELLOW"
    echo "    → Pinging google.com and 8.8.8.8..."
    
    if ping -c 1 google.com &>/dev/null || ping -c 1 8.8.8.8 &>/dev/null; then
        log "[✓] Internet connected" "$GREEN"
        echo "    → Connection successful"
        return 0
    else
        log "[✗] No internet connection" "$RED"
        echo "    → Please check your network and try again"
        exit 1
    fi
}

check_root() {
    if [[ $EUID -eq 0 ]]; then
        log "[✓] Running as root" "$GREEN"
        SUDO=""
    else
        log "[*] Not running as root" "$YELLOW"
        echo "    → Will use sudo for installations (you may be prompted for password)"
        SUDO="sudo"
    fi
}

install_all_dependencies() {
    log "\n[+] PHASE 1: INSTALLING DEPENDENCIES" "$PURPLE"
    echo "    → This is the LONGEST step (5-10 minutes)"
    echo "    → Only happens on FIRST RUN"
    echo "    → Subsequent runs will be INSTANT"
    echo ""
    
    # Update package lists
    log "[*] Step 1/6: Updating package lists..." "$CYAN"
    echo "    → Running: sudo apt update"
    $SUDO apt update -y
    log "[✓] Package lists updated" "$GREEN"
    echo ""
    
    # Install Go
    if ! command -v go &> /dev/null; then
        log "[*] Step 2/6: Installing Go programming language..." "$CYAN"
        echo "    → Download size: ~120MB"
        echo "    → This enables installation of Go-based tools"
        wget -q --show-progress https://golang.org/dl/go1.21.0.linux-amd64.tar.gz
        echo "    → Extracting Go to /usr/local..."
        $SUDO tar -C /usr/local -xzf go1.21.0.linux-amd64.tar.gz
        export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin
        rm go1.21.0.linux-amd64.tar.gz
        log "[✓] Go installed successfully" "$GREEN"
    else
        log "[✓] Go already installed (skipping)" "$GREEN"
    fi
    echo ""
    
    # Install Python and basic tools
    log "[*] Step 3/6: Installing Python and basic tools..." "$CYAN"
    echo "    → Packages: python3, python3-pip, git, curl, wget, jq, dnsutils"
    $SUDO apt install -y python3 python3-pip git curl wget jq dnsutils massdns
    log "[✓] Basic tools installed" "$GREEN"
    echo ""
    
    # Install main discovery tools
    log "[*] Step 4/6: Installing subdomain discovery tools..." "$CYAN"
    echo "    → Tools: findomain, assetfinder, subfinder, amass"
    echo "    → Each tool is 10-30MB"
    $SUDO apt install -y findomain assetfinder subfinder amass
    log "[✓] Discovery tools installed" "$GREEN"
    echo ""
    
    # Install httpx
    if ! command -v httpx &>/dev/null && ! command -v httpx-toolkit &>/dev/null; then
        log "[*] Step 5/6: Installing httpx (live probing tool)..." "$CYAN"
        echo "    → Compiling from source (takes 1-2 minutes)"
        go install -v github.com/projectdiscovery/httpx/cmd/httpx@latest
        $SUDO cp ~/go/bin/httpx /usr/local/bin/ 2>/dev/null
        log "[✓] httpx installed" "$GREEN"
    else
        log "[✓] httpx already installed" "$GREEN"
    fi
    echo ""
    
    # Install Sublist3r
    if ! command -v sublist3r &>/dev/null; then
        log "[*] Step 6/6: Installing Sublist3r (Python tool)..." "$CYAN"
        echo "    → Cloning from GitHub"
        cd /tmp
        git clone https://github.com/aboul3la/Sublist3r.git
        cd Sublist3r
        echo "    → Installing Python dependencies"
        pip3 install -r requirements.txt
        $SUDO cp sublist3r.py /usr/local/bin/sublist3r
        $SUDO chmod +x /usr/local/bin/sublist3r
        cd ~
        rm -rf /tmp/Sublist3r
        log "[✓] Sublist3r installed" "$GREEN"
    else
        log "[✓] Sublist3r already installed" "$GREEN"
    fi
    
    log "[✓] ALL DEPENDENCIES INSTALLED SUCCESSFULLY!" "$GREEN"
    echo "    → Total time: 5-10 minutes"
    echo "    → Next runs will be INSTANT (2-3 seconds)"
    echo ""
}

verify_installations() {
    log "[*] Verifying all tools are working..." "$YELLOW"
    echo ""
    
    local tools=("findomain" "assetfinder" "subfinder" "amass" "sublist3r" "httpx-toolkit")
    local all_good=true
    
    for tool in "${tools[@]}"; do
        if command -v "$tool" &>/dev/null; then
            version=$($tool --version 2>/dev/null | head -n1)
            echo -e "  ${GREEN}[✓]${NC} $tool - INSTALLED ${version:+($version)}"
        elif command -v "${tool%-toolkit}" &>/dev/null; then
            echo -e "  ${GREEN}[✓]${NC} ${tool%-toolkit} - INSTALLED"
        else
            echo -e "  ${RED}[✗]${NC} $tool - MISSING"
            all_good=false
        fi
    done
    
    echo ""
    if $all_good; then
        log "[✓] All tools verified and ready!" "$GREEN"
    else
        log "[!] Some tools are missing but script will continue" "$YELLOW"
    fi
}

setup_workspace() {
    local domain=$1
    local timestamp=$(date +"%Y%m%d_%H%M%S")
    local workspace="${domain}_${timestamp}"
    
    mkdir -p "$workspace"/{raw,processed,logs}
    echo "$workspace"
}

run_enumeration() {
    local domain=$1
    local workspace=$2
    local all_subs="${workspace}/raw/all_subs.txt"
    local unique_subs="${workspace}/processed/unique_subs.txt"
    
    log "\n[+] PHASE 2: SUBDOMAIN ENUMERATION" "$PURPLE"
    echo "    → Searching for all subdomains of $domain"
    echo "    → Using 5 different tools for maximum coverage"
    echo ""
    
    > "$all_subs"
    local count=0
    
    # Assetfinder
    if command -v assetfinder &>/dev/null; then
        log "[*] Running assetfinder..." "$CYAN"
        echo "    → Fast subdomain discovery tool by TomNomNom"
        assetfinder --subs-only "$domain" 2>/dev/null >> "$all_subs"
        local found=$(tail -n +1 "$all_subs" 2>/dev/null | wc -l)
        log "[✓] assetfinder found $(($found - $count)) subdomains" "$GREEN"
        count=$found
    fi
    
    # Subfinder
    if command -v subfinder &>/dev/null; then
        log "[*] Running subfinder..." "$CYAN"
        echo "    → Passive subdomain enumeration from multiple sources"
        subfinder -d "$domain" -silent 2>/dev/null >> "$all_subs"
        local found=$(sort -u "$all_subs" 2>/dev/null | wc -l)
        log "[✓] subfinder added $(($found - $count)) new subdomains" "$GREEN"
        count=$found
    fi
    
    # Findomain
    if command -v findomain &>/dev/null; then
        log "[*] Running findomain..." "$CYAN"
        echo "    → Fastest subdomain discovery tool"
        findomain -t "$domain" -q 2>/dev/null >> "$all_subs"
        local found=$(sort -u "$all_subs" 2>/dev/null | wc -l)
        log "[✓] findomain added $(($found - $count)) new subdomains" "$GREEN"
        count=$found
    fi
    
    # Amass
    if command -v amass &>/dev/null; then
        log "[*] Running amass (passive)..." "$CYAN"
        echo "    → OWASP Amass - thorough but slower"
        amass enum -passive -d "$domain" -o "${workspace}/raw/amass_temp.txt" >/dev/null 2>&1
        if [[ -f "${workspace}/raw/amass_temp.txt" ]]; then
            cat "${workspace}/raw/amass_temp.txt" >> "$all_subs"
            rm "${workspace}/raw/amass_temp.txt"
            local found=$(sort -u "$all_subs" 2>/dev/null | wc -l)
            log "[✓] amass added $(($found - $count)) new subdomains" "$GREEN"
            count=$found
        fi
    fi
    
    # Sublist3r
    if command -v sublist3r &>/dev/null; then
        log "[*] Running sublist3r..." "$CYAN"
        echo "    → Python-based subdomain enumeration"
        sublist3r -d "$domain" -o "${workspace}/raw/sublist3r_temp.txt" >/dev/null 2>&1
        if [[ -f "${workspace}/raw/sublist3r_temp.txt" ]]; then
            cat "${workspace}/raw/sublist3r_temp.txt" >> "$all_subs"
            rm "${workspace}/raw/sublist3r_temp.txt"
            local found=$(sort -u "$all_subs" 2>/dev/null | wc -l)
            log "[✓] sublist3r added $(($found - $count)) new subdomains" "$GREEN"
            count=$found
        fi
    fi
    
    # Remove duplicates
    sort -u "$all_subs" > "$unique_subs"
    local total=$(wc -l < "$unique_subs")
    
    log "[✓] ENUMERATION COMPLETE!" "$GREEN"
    echo "    → Total unique subdomains found: $total"
    echo "    → Raw results: $workspace/raw/all_subs.txt"
    echo "    → Unique list: $workspace/processed/unique_subs.txt"
    echo ""
    
    echo "$unique_subs"
}

check_live() {
    local subdomains_file=$1
    local workspace=$2
    local live_file="${workspace}/processed/live_subs.txt"
    local live_http_file="${workspace}/processed/live_with_http.txt"
    
    log "\n[+] PHASE 3: CHECKING LIVE SUBDOMAINS" "$PURPLE"
    echo "    → Testing which subdomains are actually active"
    echo "    → Getting HTTP status codes and server info"
    echo ""
    
    if [[ ! -s "$subdomains_file" ]]; then
        log "[-] No subdomains to check" "$RED"
        return 1
    fi
    
    local total=$(wc -l < "$subdomains_file")
    echo "    → Testing $total subdomains with 100 concurrent threads"
    echo "    → This may take 1-2 minutes"
    echo ""
    
    # Use httpx
    if command -v httpx-toolkit &>/dev/null; then
        log "[*] Probing with httpx-toolkit..." "$CYAN"
        cat "$subdomains_file" | httpx-toolkit -silent \
            -status-code \
            -title \
            -web-server \
            -follow-redirects \
            -threads 100 \
            -timeout 5 > "$live_http_file" 2>/dev/null
        
        cut -d' ' -f1 "$live_http_file" > "$live_file" 2>/dev/null
        
    elif command -v httpx &>/dev/null; then
        log "[*] Probing with httpx..." "$CYAN"
        cat "$subdomains_file" | httpx -silent \
            -status-code \
            -title \
            -web-server \
            -follow-redirects \
            -threads 100 \
            -timeout 5 > "$live_http_file" 2>/dev/null
        
        cut -d' ' -f1 "$live_http_file" > "$live_file" 2>/dev/null
    fi
    
    local live_count=$(wc -l < "$live_file" 2>/dev/null || echo "0")
    
    log "[✓] LIVE CHECK COMPLETE!" "$GREEN"
    echo "    → Live subdomains found: $live_count out of $total"
    echo "    → Live rate: $(echo "scale=2; $live_count*100/$total" | bc)%"
    echo ""
    
    # Show status code breakdown
    if [[ -s "$live_http_file" ]]; then
        echo "    HTTP Status Breakdown:"
        echo "    --------------------"
        grep -o "\[[0-9]*\]" "$live_http_file" | sort | uniq -c | sort -rn | while read count status; do
            echo "      $status : $count"
        done
        echo ""
        
        echo "    Top 10 Live Subdomains:"
        echo "    ----------------------"
        head -n 10 "$live_http_file" | while read line; do
            echo "      $line"
        done
    fi
    
    echo "$live_file"
}

generate_report() {
    local domain=$1
    local workspace=$2
    local live_file=$3
    local unique_subs=$4
    local report_file="${workspace}/final_report.txt"
    
    log "\n[+] PHASE 4: GENERATING REPORTS" "$PURPLE"
    echo "    → Creating human-readable and machine-readable reports"
    echo ""
    
    # Text report
    log "[*] Creating text report..." "$CYAN"
    {
        echo "=============================================="
        echo "      AUTO SUBDOMAIN HUNTER - FINAL REPORT"
        echo "=============================================="
        echo ""
        echo "Target Domain: $domain"
        echo "Scan Date: $(date)"
        echo "Workspace: $workspace"
        echo ""
        echo "STATISTICS:"
        echo "  Total Subdomains Found: $(wc -l < "$unique_subs" 2>/dev/null || echo "0")"
        echo "  Live Subdomains: $(wc -l < "$live_file" 2>/dev/null || echo "0")"
        echo ""
        echo "LIVE SUBDOMAINS (with HTTP info):"
        echo "----------------------------------------------"
        
        if [[ -f "${workspace}/processed/live_with_http.txt" ]]; then
            cat "${workspace}/processed/live_with_http.txt"
        else
            cat "$live_file"
        fi
        
        echo ""
        echo "ALL SUBDOMAINS:"
        echo "----------------------------------------------"
        cat "$unique_subs"
        
    } > "$report_file"
    log "[✓] Text report created: $report_file" "$GREEN"
    
    # JSON report
    if command -v jq &>/dev/null && [[ -f "$live_file" ]]; then
        log "[*] Creating JSON report..." "$CYAN"
        {
            echo "{"
            echo "  \"domain\": \"$domain\","
            echo "  \"scan_date\": \"$(date -Iseconds)\","
            echo "  \"statistics\": {"
            echo "    \"total_subdomains\": $(wc -l < "$unique_subs" 2>/dev/null || echo "0"),"
            echo "    \"live_subdomains\": $(wc -l < "$live_file" 2>/dev/null || echo "0")"
            echo "  },"
            echo "  \"results\": ["
            
            if [[ -f "${workspace}/processed/live_with_http.txt" ]]; then
                local first=true
                while read url status title server; do
                    if $first; then
                        first=false
                    else
                        echo ","
                    fi
                    echo -n "    {\"url\":\"$url\",\"status_code\":$status,\"title\":\"$title\",\"server\":\"$server\"}"
                done < "${workspace}/processed/live_with_http.txt"
            fi
            
            echo ""
            echo "  ]"
            echo "}"
        } > "${workspace}/results.json"
        log "[✓] JSON report created: $workspace/results.json" "$GREEN"
    fi
    
    # CSV report
    if [[ -f "${workspace}/processed/live_with_http.txt" ]]; then
        log "[*] Creating CSV report..." "$CYAN"
        echo "URL,Status Code,Title,Server" > "${workspace}/results.csv"
        cat "${workspace}/processed/live_with_http.txt" | awk '{print $1","$2","$3","$4}' >> "${workspace}/results.csv" 2>/dev/null
        log "[✓] CSV report created: $workspace/results.csv" "$GREEN"
    fi
    
    echo ""
    log "[✓] ALL REPORTS GENERATED SUCCESSFULLY!" "$GREEN"
}

# Main function
main() {
    print_banner
    
    if [[ $# -eq 0 ]] || [[ "$1" == "-h" ]] || [[ "$1" == "--help" ]]; then
        echo "USAGE: $0 <domain> [output_directory]"
        echo ""
        echo "EXAMPLES:"
        echo "  $0 example.com              # Basic scan"
        echo "  $0 example.com ./results    # Custom output directory"
        echo "  $0 -h                       # Show this help"
        echo ""
        echo "WHAT HAPPENS:"
        echo "  1. First run: Installs all tools (5-10 minutes)"
        echo "  2. Subsequent runs: Instant (2-3 seconds)"
        echo "  3. Finds all subdomains using 5+ tools"
        echo "  4. Checks which ones are live"
        echo "  5. Generates TXT, JSON, and CSV reports"
        exit 0
    fi
    
    local domain=$1
    local custom_dir=$2
    
    # Validate domain
    if ! [[ $domain =~ ^[a-zA-Z0-9][a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$ ]]; then
        echo "ERROR: Invalid domain format: $domain"
        echo "       Use format like: example.com"
        exit 1
    fi
    
    check_internet
    check_root
    
    # Setup workspace
    if [[ -n $custom_dir ]]; then
        workspace="$custom_dir"
        mkdir -p "$workspace"/{raw,processed,logs}
    else
        workspace=$(setup_workspace "$domain")
    fi
    
    log "[✓] Workspace created: $workspace" "$GREEN"
    echo ""
    
    # Install and verify tools
    install_all_dependencies
    verify_installations
    
    # ===== SCAN START MESSAGE =====
    print_color "\n════════════════════════════════════════════════════════════" "$BLUE"
    print_color "                    SCAN STARTING NOW!                      " "$GREEN"
    print_color "════════════════════════════════════════════════════════════" "$BLUE"
    print_color "[*] Target Domain: $domain" "$CYAN"
    print_color "[*] Workspace: $workspace" "$CYAN"
    print_color "[*] Start Time: $(date +"%H:%M:%S")" "$CYAN"
    print_color "[*] Estimated Duration: 2-5 minutes (depends on domain size)" "$YELLOW"
    print_color "[*] Tools: assetfinder, subfinder, findomain, amass, sublist3r, httpx" "$CYAN"
    print_color "════════════════════════════════════════════════════════════" "$BLUE"
    echo ""
    # ===== END SCAN START MESSAGE =====
    
    unique_subs=$(run_enumeration "$domain" "$workspace")
    
    if [[ -f "$unique_subs" ]] && [[ -s "$unique_subs" ]]; then
        live_file=$(check_live "$unique_subs" "$workspace")
        generate_report "$domain" "$workspace" "$live_file" "$unique_subs"
        
        echo ""
        log "════════════════════════════════════════════════════════════" "$BLUE"
        log "                    SCAN COMPLETE!                          " "$GREEN"
        log "════════════════════════════════════════════════════════════" "$BLUE"
        echo ""
        echo "  📁 Workspace: $workspace"
        echo "  📄 Text Report: $workspace/final_report.txt"
        echo "  📊 JSON Report: $workspace/results.json"
        echo "  📈 CSV Report: $workspace/results.csv"
        echo ""
        echo "  📊 Summary:"
        echo "    • Total subdomains: $(wc -l < "$unique_subs")"
        echo "    • Live subdomains: $(wc -l < "$live_file")"
        echo "    • End Time: $(date +"%H:%M:%S")"
        echo ""
        log "════════════════════════════════════════════════════════════" "$BLUE"
    else
        log "[-] No subdomains found for $domain" "$RED"
    fi
}

# Run main function
main "$@"