# USB/IP

USB/IP is a general USB device sharing system over IP network. To share USB devices between computers with their full functionality, USB/IP encapsulates "USB I/O messages" into TCP/IP payloads and transmits them between computers.

USB/IP is now built-in in the latest Linux kernel (e.g. Ubuntu 26.04 HWE kernel 7.x).  __WARNING :__ It can share USB devices over the _INTERNAL_ (_LOCAL_) network with no protection or encryption (*__USE WITH CARE__*).  You can access the shared USB devices on your desktop as a USB device mounted locally, you can even play videoes over it too.  

For security purpose, you may consider to : 

- [x] hardening the systemd service file at /lib/systemd/system/ (e.g. NoNewPrivileges, ProtectSystem and etc.)       
- [x] using SSH tunneling (with iptables) for direct connection (for internel network - local)     
- [x] using TailScale (or HeadScale - open source) (for remote network - internet)            

The host can be Linux computer or Android device.  The client can be Linux or Windows, but Android does not supported at the moment.

__The scripts are written in Bash and it is a stable version.  It is released under the GPL 3.0 License.__      

__Usage :__

The host (Linux server/ Android device) can share :

- [x] USB Printers    
- [x] USB Sticks   
- [x] USB HDDs/SSds    
- [ ] any more?    

The host (Android device) can be :

- [x] TV Boxes    
- [x] Smartphones/Tablets    
- [ ] any more?    

## Ubuntu 26.04 LTS (Host and Client)

### [A] server side

```
sudo apt install linux-tools-common linux-tools-generic

echo "usbip_host" | sudo tee -a /etc/modules 
echo "usbip_core" | sudo tee -a /etc/modules 

sudo usermod $USER -a -G dialout

sudo install -d -m 755 -o root -g root /etc/usbip
sudo install -m 640 -o root -g root usbip-server.conf /etc/usbip/usbip-server.conf
sudo install -m 755 usbip-server.sh /usr/bin/usbip-server.sh
sudo install -m 755 usbip-server-stop.sh /usr/bin/usbip-server-stop.sh 
sudo install -m 755 usbip-server-poststop.sh /usr/bin/usbip-server-poststop.sh 

sudo install -m 644 usbip-service.service /etc/systemd/system/

echo 'ACTION=="add", SUBSYSTEM=="usb", ENV{DEVTYPE}=="usb_device", \
  RUN+="/bin/systemctl --no-block kill --kill-who=main -s SIGUSR1 usbip-server.service"' | sudo tee -a /etc/udev/rules.d/99-usbip-hotplug.rules

sudo systemctl daemon-reload
sudo systemctl enable usbip-server.service
sudo systemctl start usbip-server.service
```

__Debug :__

```
journalctl -t usbip-server -f
```

### [B] client side

```
sudo apt install linux-tools-common linux-tools-generic

echo "usbip_host" | sudo tee -a /etc/modules 
echo "usbip_core" | sudo tee -a /etc/modules 
echo "usbip_vudc" | sudo tee -a /etc/modules 
echo "usbip_host" | sudo tee -a /etc/modules 
echo "vhci_hcd" | sudo tee -a /etc/modules 

sudo usermod $USER -a -G dialout

sudo install -d -m 755 -o root -g root /etc/usbip
sudo install -m 640 -o root -g root usbip-client.conf /etc/usbip/usbip-client.conf
sudo install -m 755 usbip-client.sh /usr/bin/usbip-client.sh 
sudo install -m 755 usbip-client-stop.sh /usr/bin/usbip-client-stop.sh

sudo install -m 644 usbip-client.service /etc/systemd/system/

sudo systemctl daemon-reload
sudo systemctl enable usbip-client.service
sudo systemctl start usbip-client.service
```

__Debug :__

```
journalctl -t usbip-client -f
```

## Android (Host)  - Tested

[Android USB/IP server app - share USB devices over network](https://github.com/yunsmall/Android-Usbipdcpp) can be downloaded from developer's GitHub and it is an open source project.

## Windows (Client) - Not Tested Yet

[USB/IP Client for Windows](https://github.com/vadimgrn/usbip-win2) can be downloaded from developer's GitHub and it is an open source project.

Samiux           
Nov 04, 2026, Hong Kong, China             
