#!/bin/bash 

install_dir="/home/elitesec/Desktop"
archive_file="kali-linux-2025.1c-qemu-amd64.7z"
kali_qcow="${install_dir}/kali-linux-2025.1c-qemu-amd64.qcow2"

if [ ! -f $kali_qcow ]; then
    if [ ! -f $archive_file ]; then
        echo "Downloading $archive_file"
        wget  -O ${install_dir}/${archive_file} https://cdimage.kali.org/kali-2025.1c/$archive_file
        echo "Download complete!"
    fi

    # Check if py7zr is installed
    if ! pip show py7zr &> /dev/null; then
          echo "Installing"
          pip install py7zr
    fi
    
      # Extract the archive using Python :0
      echo "Extracting $archive_file"
      python3 -m py7zr x ${install_dir}/${archive_file} $install_dir
     echo "Extraction complete!"
    rm -f ${install_dir}/${archive_file}
    cp run.sh ~/
    chmod u+x ~/run.sh
fi

IMAGE_PATH=$kali_qcow
SSHPORT=2222

qemu-system-x86_64 \
-display gtk,zoom-to-fit=on,grab-on-hover=on,window-close=off \
-cpu host \
-full-screen \
-enable-kvm \
-netdev user,id=hostnet0,hostfwd=tcp::${SSHPORT}-:22 \
-usb -device qemu-xhci,id=xhci -device usb-mouse -device usb-kbd \
-device virtio-vga \
-device intel-hda \
-device hda-duplex \
-device virtio-net,netdev=hostnet0 \
-m 12G \
-smp 20 \
-daemonize \
${IMAGE_PATH}