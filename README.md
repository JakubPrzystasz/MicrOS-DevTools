# MicrOS-DevTools
Tools for configuring MicrOS development environment on GNU/Linux and WSL.

## Instructions:

### GNU/Linux
First of all you will need to install few packages using your package manager.
You will need:
- nasm
- mtools
- curl (should be already installed, but check to be sure)
- build-essential (this varies from distribution to distribution, contains tools like make and necessary libraries)

Next up is downloading and running the `configure.sh` script supplying it with flags and arguments:
- `-w <workspace directory>` - directory where you cloned the [MicrOS](https://github.com/Tearth/MicrOS) repo,
- `-t <number of threads>` - specify a number of threads to use when compiling MicrOS (optional)
```
$ curl -LO https://raw.githubusercontent.com/jaenek/MicrOS-DevTools/master/configure.sh
$ chmod +x configure.sh
$ ./configure.sh -w <workspace directory>
```
It will ask for sudo permission beacause it needs to install the cross complier to `/opt/` directory.

## WSL (Windows 10)
Start with installation of a Windows Subsystem for Linux. You can follow a guide [here](https://docs.microsoft.com/en-us/windows/wsl/install-win10). You should install the **Ubuntu distribution**.

Then open your Ubuntu WSL and install few packages using apt:
```
$ sudo apt update && sudo apt upgrade
$ sudo apt install nasm mtools build-essential
```

Next prepare a path to your qemu directory it should look something like this `"C:\Program Files\qemu\qemu-system-i386.exe"`, also open Ubuntu WSL in the directory where you cloned the [MicrOS](https://github.com/Tearth/MicrOS) repo. Your command prompt should look something like this:
```
<user>@windows:/mnt/c/Users/<user>/MicrOS$
```
  
Next up is downloading and running the `configure.sh` script supplying it with flags and arguments:
- `-w <workspace directory>` - directory where you cloned the [MicrOS](https://github.com/Tearth/MicrOS) repo,
- `-t <number of threads>` - specify a number of threads to use when compiling MicrOS (optional),
- `-q <qemu path>` - this is the path from earlier `"C:\Program Files\qemu\qemu-system-i386.exe"`,
- `--wsl` - this is an indication to configure a Windows environment.
```
$ curl -LO https://raw.githubusercontent.com/jaenek/MicrOS-DevTools/master/configure.sh
$ chmod +x configure.sh
$ ./configure.sh -w <workspace directory> -q <qemu path> --wsl
```
If you followed the previous instructions the last line should look like this:
```
$ sudo ./configure.sh -w ./ -q "C:\Program Files\qemu\qemu-system-i386.exe" --wsl
```
It might ask for sudo permission beacause it needs to install the cross complier to `/opt/` directory, in that case just type the password that you set when setting up a user in WSL.
