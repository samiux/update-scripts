# update-scripts

## Update bash scripts for Ubuntu and Kali Linux

For Kali Linux 2020.1 or later, you are required to install "reboot-notifier".

```bash
sudo apt install reboot-notifier
```

### Set up :

```bash
chmod +x update_ubuntu
chmod +x update_kali
```

### Usage :

```bash
sudo ./update_ubuntu

sudo ./update_kali
```

## Update bash scripts for GitHub (local copies)

### Set up :

```bash
chmod +x github_update
chmod +x github_delete
```

### Usage :

```bash
./github_update

./github_delete all
./github_delete croissants
```
