import sys
from collections import Counter

def process_log_file(logfile):
    try:
        with open(logfile, 'r') as file:
            ip_addresses = [line.split()[1] for line in file]
        return Counter(ip_addresses)
    except FileNotFoundError:
        print(f"Error: File '{logfile}' not found.")
        sys.exit(1)
    except Exception as e:
        print(f"An error occurred: {e}")
        sys.exit(1)

def main(logfile):
    ip_counts = process_log_file(logfile)
    for ip, count in ip_counts.most_common():
        print(f"{count} {ip}")

if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("Usage: python main.py <logfile>")
        sys.exit(1)
    logfile = sys.argv[1]
    main(logfile)
