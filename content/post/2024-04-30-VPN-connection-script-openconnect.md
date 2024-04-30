+++
title = "Using OpenConnect and Expect to make my VPN life easier"
date = "2024-04-30"
+++

Companies in the past have had a mix of VPNs that I needed to connect to daily. I run Linux, and would rather have things in a script than set up in a GUI. I set out to automate the connection and disconnection. Making daily tasks as simple, easy and frictionless as possible leaves me free to focus on more important things. I've found that the upfront cost in time is well worth it.

The latest was a Cisco AnyConnect VPN. You also needed to type the first 4 characters of a username as the start of your password, followed by a OTP code. This small pain was one of the things I wanted to automate away.

Eventually, I plan to fully automate the OTP entry, but I've not found a solution I like. Ideally, this OTP would be cloud saved, with an API to request them.

```
#!/usr/bin/expect -f

# This script is designed to make connecting to a AnyConnect VPN using the openconnect.
#   It will pre-populate the last 4 chars of your user ID into the password prompt for you.

# SETUP: Set this script as executable and run. e.g. ./script, Note, this script is not run with bash directly. 

##### VARIABLES TO SET #######
set user_id "XXXXXX"
# set user_id [lindex $argv 0]  # for passing the user_id on the cli
set vpn_endpoint "CORPVPN.COM"
set vpn_binary "openconnect"
set auth_group "AUTH_GROUP_1" 
##############################

# Function to display help message
proc display_help {} {
    #puts "Set the correct variables at the top of this script."
    #puts ""
    puts "To connect, run the script. If already connected, it will display the connection status."
    puts ""
    puts "Options:"
    puts "  disconnect|down    Disconnect from the VPN"
    puts "  -h, --help, help   Display this help message"
}

# Function to check if a binary is available on the path. Exit gracefully if the vpn client isn't installed
proc check_binary_availability {vpn_binary} {
    set result [catch {exec which $vpn_binary} output]
    if {$result != 0} {
        puts "Error: Binary '$vpn_binary' is not found on the system path. Exiting..."
        exit 1
    }
}

proc check_user_id_length {user_id} {
    if {[string length $user_id] != 8} {
        send_user "Error: User ID must be 8 characters long\n"
        exit 1
    }
}

proc check_vpn_status {vpn_binary} {
    set status [catch {exec nmcli con show --active | grep -i tun} result]
    if {$status == 0} {
        return "VPN Connection is active"
    } else {
        return "VPN Connection is NOT active"
    }
}

proc connect_vpn {vpn_binary user_id auth_group vpn_endpoint} {
    # grab the last 4 chars of the username, this is typed automatically before the password
    set username_short [string range $user_id end-3 end]

    # Spawn the VPN command
    spawn sudo $vpn_binary --background --user=$user_id --authgroup=$auth_group $vpn_endpoint
    
    # Wait for the password prompt
    expect "Password:"
    
    # Send the password
    send "$username_short"

    # Now wait for additional input from the user. This is the rest of the OTP password
    interact "Password:" {
        expect_user -re "(.*)\n"
        send "$expect_out(1,string)\r"
    }
}

proc is_vpn_connected {status} {
    return [string match -nocase "*VPN Connection is active*" $status]
}

proc attempt_connection {vpn_binary user_id auth_group vpn_endpoint} {
    connect_vpn $vpn_binary $user_id $auth_group $vpn_endpoint
    
    for {set i 0} {$i < 5} {incr i} {
        after 2000 ;  # Wait for 2 seconds before checking status again
        set status [check_vpn_status $vpn_binary]
        if { [is_vpn_connected $status] } {
            puts "VPN connected successfully."
            puts $status
            return
        }
    }
    
    puts "Failed to connect to VPN after multiple attempts. Exiting."
    exit 1
}

proc disconnect_vpn {vpn_binary vpn_status} {
    if {[is_vpn_connected $vpn_status]} {
        spawn sudo pkill --signal SIGINT $vpn_binary
    } else {
        puts $vpn_status
        #puts "Unknown VPN status. Exiting."
        exit 1
    }

    # Now wait for additional input from the user. This is the rest of the OTP password
    interact "assword:" {
        expect_user -re "(.*)\n"
        send "$expect_out(1,string)\r"
    }
}

# Check if the user requested help
if {[lsearch -exact $argv "-h"] != -1 || [lsearch -exact $argv "--help"] != -1 || [lsearch -exact $argv "help"] != -1} {
    display_help
    exit 0
}

# Check the correct binaries are installed
check_binary_availability $vpn_binary

# Set the current VPN connection status
set vpn_status [check_vpn_status $vpn_binary]

# Check if the user requested to disconnect VPN
if {[lindex $argv 0] eq "disconnect" || [lindex $argv 0] eq "down"} {
    disconnect_vpn $vpn_binary $vpn_status
    exit 0
}

# If VPN is already connected, show status. If not, try to connect
if {[is_vpn_connected $vpn_status]} {
    puts $vpn_status
    exit 0
} elseif {[string match -nocase "*Not active*" $vpn_status ]} {
    check_user_id_length $user_id
    attempt_connection $vpn_binary $user_id $auth_group $vpn_endpoint
} else {
    puts $vpn_status
    puts "Unknown VPN status. Exiting."
    exit 1
}
```
