# AUTOSAR_Xenomai_Package
This buildroot package add an custom Xenomai 3.0.2 to Buildroot.
This Xenomai implements an AUTOSAR skin and add a Code Generator to build the AUTOSAR Skin with an AUTOSAR Model (.arxml)

# ADD Package to Buildroot

Replace the xenomai package into buildroot by this one.

# ADD Skin to rootfs

In Buildroot menuconfig :
Target packages ---> Real-Time ---> Xenomai Userspace

Choose Xenomai Core (Cobalt or Mercury)
Add some Skin

For AUTOSAR skin library : 
Add an AUTOSAR Model path


Add Ipipe Patch : 
Kernel ---> Linux Kernel Extensions ---> Adeos/Xenomai Real-time patch
