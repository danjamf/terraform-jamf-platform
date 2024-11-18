packer {
  required_plugins {
    tart = {
      version = ">= 1.12.0"
      source  = "github.com/cirruslabs/tart"
    }
  }
}

source "tart-cli" "tart" {
  from_ipsw    = "https://updates.cdn-apple.com/2024FallFCS/fullrestores/072-12302/3786987A-AD94-4BFB-81B8-56D3841CA81B/UniversalMac_15.1_24B2083_Restore.ipsw"
  vm_name      = "experiencejamf"
  cpu_count    = 4
  memory_gb    = 8
  disk_size_gb = 30
  ssh_password = "admin"
  ssh_username = "admin"
  ssh_timeout  = "300s"
  boot_command = [
    # hello, hola, bonjour, etc.
    "<wait60s><spacebar>",
    # Language: most of the times we have a list of "English"[1], "English (UK)", etc. with
    # "English" language already selected. If we type "english", it'll cause us to switch
    # to the "English (UK)", which is not what we want. To solve this, we switch to some other
    # language first, e.g. "Italiano" and then switch back to "English". We'll then jump to the
    # first entry in a list of "english"-prefixed items, which will be "English".
    #
    # [1]: should be named "English (US)", but oh well 🤷
    "<wait30s>italiano<esc>english<enter>",
    # Select Your Country and Region
    "<wait30s>united states<leftShiftOn><tab><leftShiftOff><spacebar>",
    # Written and Spoken Languages
    "<wait10s><leftShiftOn><tab><leftShiftOff><spacebar>",
    # Accessibility
    "<wait10s><leftShiftOn><tab><leftShiftOff><spacebar>",
    # Data & Privacy
    "<wait10s><leftShiftOn><tab><leftShiftOff><spacebar>",
    # Migration Assistant
    "<wait10s><tab><tab><tab><spacebar>",
    # Sign In with Your Apple ID
    "<wait10s><leftShiftOn><tab><leftShiftOff><leftShiftOn><tab><leftShiftOff><spacebar>",
    # Are you sure you want to skip signing in with an Apple ID?
    "<wait10s><tab><spacebar>",
    # Terms and Conditions
    "<wait10s><leftShiftOn><tab><leftShiftOff><spacebar>",
    # I have read and agree to the macOS Software License Agreement
    "<wait10s><tab><spacebar>",
    # Create a Computer Account
    "<wait10s>admin<tab><tab>admin<tab>admin<tab><tab><tab><spacebar>",
    # Enable Location Services
    "<wait120s><leftShiftOn><tab><leftShiftOff><spacebar>",
    # Are you sure you don't want to use Location Services?
    "<wait10s><tab><spacebar>",
    # Select Your Time Zone
    "<wait10s><tab>UTC<enter><leftShiftOn><tab><leftShiftOff><spacebar>",
    # Analytics
    "<wait10s><leftShiftOn><tab><leftShiftOff><spacebar>",
    # Screen Time
    "<wait10s><tab><spacebar>",
    # Siri
    "<wait10s><tab><spacebar><leftShiftOn><tab><leftShiftOff><spacebar>",
    # Choose Your Look
    "<wait10s><leftShiftOn><tab><leftShiftOff><spacebar>",
    # Welcome to Mac
    "<wait10s><spacebar>",
    # Enable Keyboard navigation
    # This is so that we can navigate the System Settings app using the keyboard
    "<wait10s><leftAltOn><spacebar><leftAltOff>Terminal<enter>",
    "<wait10s>defaults write NSGlobalDomain AppleKeyboardUIMode -int 3<enter>",
    "<wait10s><leftAltOn>q<leftAltOff>",
    # Now that the installation is done, open "System Settings"
    "<wait10s><leftAltOn><spacebar><leftAltOff>System Settings<enter>",
    # Navigate to "Sharing"
    "<wait10s><leftAltOn>f<leftAltOff>sharing<enter>",
    # Navigate to "Screen Sharing" and enable it
    "<wait10s><tab><tab><tab><tab><tab><spacebar>",
    # Navigate to "Remote Login" and enable it
    "<wait10s><tab><tab><tab><tab><tab><tab><tab><tab><tab><tab><tab><tab><spacebar>",
    # Quit System Settings
    "<wait10s><leftAltOn>q<leftAltOff>",
  ]

  // A (hopefully) temporary workaround for Virtualization.Framework's
  // installation process not fully finishing in a timely manner
  create_grace_time = "30s"
}

variable "jamf_url" {
  type        = string
  description = "Jamf Cloud URL"
  default     = "https://experience.jamfcloud.com"
}

build {
  sources = ["source.tart-cli.tart"]

  provisioner "shell" {
    inline = [
      // Enable passwordless sudo
      "echo admin | sudo -S sh -c \"mkdir -p /etc/sudoers.d/; echo 'admin ALL=(ALL) NOPASSWD: ALL' | EDITOR=tee visudo /etc/sudoers.d/admin-nopasswd\"",
      // Enable auto-login
      "echo '00000000: 1ced 3f4a bcbc ba2c caca 4e82' | sudo xxd -r - /etc/kcpassword",
      "sudo defaults write /Library/Preferences/com.apple.loginwindow autoLoginUser admin",
      // Disable screensaver at login screen
      "sudo defaults write /Library/Preferences/com.apple.screensaver loginWindowIdleTime 0",
      // Disable screensaver for admin user
      "defaults -currentHost write com.apple.screensaver idleTime 0",
      // Prevent the VM from sleeping
      "sudo systemsetup -setsleep Off 2>/dev/null",
      // Launch Safari to populate the defaults
      "/Applications/Safari.app/Contents/MacOS/Safari &",
      "SAFARI_PID=$!",
      "disown",
      "sleep 30",
      "kill -9 $SAFARI_PID",
      // Enable Safari's remote automation
      "sudo safaridriver --enable",
      // Disable screen lock
      "sysadminctl -screenLock off -password admin",
    ]
  }

  provisioner "shell" {
    inline = [
      // Create LaunchAgent directory if it doesn't exist
      "mkdir -p /Users/admin/Library/LaunchAgents",
      // Create LaunchAgent plist
      "cat << EOF > /Users/admin/Library/LaunchAgents/com.jamfce.mdmenroll.plist",
      "<?xml version=\"1.0\" encoding=\"UTF-8\"?>",
      "<!DOCTYPE plist PUBLIC \"-//Apple//DTD PLIST 1.0//EN\" \"http://www.apple.com/DTDs/PropertyList-1.0.dtd\">",
      "<plist version=\"1.0\">",
      "<dict>",
      "    <key>Label</key>",
      "    <string>com.jamfce.mdmenroll</string>",
      "    <key>ProgramArguments</key>",
      "    <array>",
      "        <string>/bin/sh</string>",
      "        <string>-c</string>",
      "        <string>open x-apple.systempreferences:com.apple.Profiles-Settings.extension</string>",
      "    </array>",
      "    <key>RunAtLoad</key>",
      "    <true/>",
      "</dict>",
      "</plist>",
      "EOF",

      // Set proper permissions
      "chmod 644 /Users/admin/Library/LaunchAgents/com.jamfce.mdmenroll.plist",

      // Load the LaunchAgent
      "launchctl load /Users/admin/Library/LaunchAgents/com.jamfce.mdmenroll.plist",
    ]
  }

  provisioner "shell" {
    inline = [
      "cat << EOF > ~/Desktop/Enroll_Me.webloc",
      "<?xml version=\"1.0\" encoding=\"UTF-8\"?>",
      "<plist version=\"1.0\">",
      "<dict>",
      "    <key>URL</key>",
      "    <string>${var.jamf_url}/enroll</string>",
      "</dict>",
      "</plist>",
      "EOF",
    ]
  }
}