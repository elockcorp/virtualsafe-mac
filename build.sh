#!/bin/bash
TAG_VERSION=${1:-snapshot}
GIT_BRANCH=${1:-develop}

# check preconditions
if [ -z "${JAVA_HOME}" ]; then echo "JAVA_HOME not set. Run using JAVA_HOME=/Library/Java/JavaVirtualMachines/jdk-x.y.z.jdk/Contents/Home/ ./build.sh"; exit 1; fi
if [ ! -x ./tools/packager/jpackager ]; then echo "../tools/packager/jpackager not executable."; exit 1; fi
if [ ! -x ./tools/create-dmg/create-dmg.sh ]; then echo "./tools/create-dmg/create-dmg.sh not executable."; exit 1; fi
command -v jq >/dev/null 2>&1 || { echo >&2 "jq not found."; exit 1; }
command -v curl >/dev/null 2>&1 || { echo >&2 "curl not found."; exit 1; }
command -v unzip >/dev/null 2>&1 || { echo >&2 "unzip not found."; exit 1; }
command -v codesign >/dev/null 2>&1 || { echo >&2 "codesign not found. Fix by 'xcode-select --install'."; exit 1; }

# cleanup
rm -rf buildkit.zip libs app *.dmg

# download buildkit
: ' ###_VIRTUALSAFE_CHANGE_TRACKING_START_###
U2FsdGVkX18TC0AjlN+KhWa0yg/1VuhyQC/HS4iyfmZj+6MmgkCbnWUxYJ0vFnya
IzLnEJXitAgIbiWsHBoKRLE4dDf3eNGvFdBEFt+PQK4iNqczlbr96EQ/qAOB7NBh
o1R30vLkEeqGWvZrp9bQBc5GLcQ1uJ0urYHJHlxK2flXqPpa9UfEW7xI9tAiC64g
/6GT6XSawkAE6Nvv7wcngYoAocQJqLIv1CBjru+H28j1hFcmVCb9GF9ePLDduMNL
7N+QFSaXb0CP/lHoenT4IQ==
###_VIRTUALSAFE_CHANGE_TRACKING_END_### '
cp ../virtualsafe-based-on-cryptomator-1.4.10/main/buildkit/target/buildkit-mac.zip ./buildkit.zip
unzip buildkit.zip
if [ $? -ne 0 ]; then
  echo >&2 "unzipping buildkit.zip failed.";
  exit 1;
fi

# setting variables
: ' ###_VIRTUALSAFE_CHANGE_TRACKING_START_###
U2FsdGVkX1/pozg6p0m5I0KOLI6zLDKQHV99g8uopyyzR4pZiGwKKyoJIZ9xnfA/
I0PJMd1y1WCVwr3Tuswokew/t3qzSEPGl3JxTX4YjFFw7cfUEHVyNFTtkWcs5UBm
i1i/sC3aBe9cQEVepwlZo4m3Nu8dqEhn8Gx4cBEvd1sUI1DcnMPDfDqh5T8SI87V
/dlaCljDg5VTPSLbRHIzuqrdSsVuIWIP7CaGJpYtNjiwqEYME8nDQ4o9QzUINEyV
3SdHYpyyJYYT7DHpjGGoeMNFPJfwOdsVzEn9oK+X4TBubOzNvbT7ENBQo0+vABPS
7LX3Cat9PZHy1X72f1Uaq6aQk7NrJSIERL00sJpdzEmjJk1pluQNwN3x39U0lyDG
YXyc5j0VKzPu+PXyPTd4pc02uqnhi5vEojdPBLMZZU/n+qYKNLfnaqj6v9OZZP0j
+vw52J/0ue78eE3XQDQ+MWndNFBxu6xBUd2XeSkEuChB4sWqml2f+Wwzq3lr8GXc
zy6HGbKoPxq8Ctkg9NgGnPLsBjbH86dBGKtRXUeAJYmipNNWpi1C0fMBTX7ENfRv
WTyjpNEKru4zbWj19TBxBi6wsRK8e5erQvDS5E5gCfkNV/uW9ezGhLpmMvDqzzsN
ALkU/lkdvrX8bUsjfaw+HPeQ7mrfLWAZxj9tJWLaUKM=
###_VIRTUALSAFE_CHANGE_TRACKING_END_### '
COMMIT_COUNT=$(date "+%Y%m%d%H%M%S")
BUILD_VERSION=$(cat libs/version.txt)
VSAFEVERSION="2.5.5"
echo "Building VirtualSAFE ${BUILD_VERSION} (${COMMIT_COUNT})..."

# create .app
: ' ###_VIRTUALSAFE_CHANGE_TRACKING_START_###
U2FsdGVkX19kaliFy3tG1o9b4EIDsGgcDc70UtkbwbwOjaOCJZPA8G0tZjK8WAH3
17OGskeH7DtXP2+b44Yr6zfSckuyUDLM468+trHa7190kdCCO1247zhAKwa1mBCS
/uPMCSl64EAzVeu6qwYJU1ZE7Pkwt8kIPZnMkXQhqQmlj42z3hU0KxOrZd47LVyR
aOhKLDXPU6nJogRURxoW44kxyIFF9p4ljCUsmKEPG6wGPzy6eS6xSDweXE1WIfhV
m8y9xg6ZuaZSyk1bVSlQWR2jA00Pb+AIYuuPO8EqCuOvPO+0794m2Nuz0C0Xk9Qc
jJbuJA6psh1V9cQO6PqHnLkBnanzinhamSXenbbaYuOsydkHOJYslZlDZHSooR6n
wKrUagzqrBev59Ss78KxbnhF/ZXYkoW5ebY37H6lupDir/SbUykDuuWcP3Rhd5r/
oHHgLDPz22CaMcTdH5yffQwHEBstulksp6II+fRP6UDAMxs4pcUfe2qS7gffmEL+
b0BFIil7MYamZo+M8/xeTu34yYCFCsHoC6FEjKPhsNxWw28KbVBTuBl2g4VqVovF
v8kHVL46F0MoDbs1Cb3EFkL1JxzeglsLUNEwuNVI2iAzFTjBTgcbZZRNQhHZNond
ta0Mw9JaFVm4UZvpWGePztwYYs9A0GnQgbo+NW2ps4toOHaFHHke09HKmdzB1IC0
osMHROdErtU4J3RIfu9njHaT2k3uxV3IiK3BzKZ7hXZSlIGVjjEXGQKqUxNLbr17
VgZR5iv3TTKQueuz2gZzhZuOZHLDaPPoGJIpCOl7StsBhdo8W6Z34SaSSOd5QSuK
kphBLBIZ5kRjApKS1HGGsj2WFk8ufPfA3lObC6SyKXGe0591V2sJ7iXHkQAc+fFb
JxPGE/zx/TQTVUrjTuWo38mPg1mATqiCphtqSkvpXD3wCaSRIACyYFJS0MJHK0C/
3+4VToMtwo1yF0Q7PyfYN7m5P2bGQEKGwjjPkoTG/VMKY7F+hA5oNFpe4F4eZoqU
L9lhPxuV2Ynr+Ax3aDZ8aR2+EgmzbFxSwnbg178cc10srwVCvQBvcINM8SSB8x2j
53dtnGtMkTj5trukkkz571oQiwgJUNSAm1rat+Inssn1iNT0ZzUjw3eGDD99j3IY
UCE7ro6Gd9eGlqzK339rhO3RhKIFxIPXwmMhBVqwpdxz5QghVg2wkWcOsasKCYP+
vbB/eWEgiHCh1bpKTOEojOPaQ+0GebYdUoN6UeUMuelItPJBy7gmCQSLgpHXo8lN
NjCjkg9wv7EZW5jW0ivyHo06rnu8HF9j66QFQ+9KuKisDbFHTNNaFdC3Li19prap
Augp9A6alIVHiuhlLzSXUxDJRt/Yu31T8wiC69bS0Fjg8cZw5u5X+8y62XpU/lKD
5w9lLCdHhHUMmL1YuTHt85FfTSqcoWo3u26nfF36lrZ4yclfzKtnuLUIkDWGT9eM
PvVD1yk9db57VgAcCUMU/ciqLsFgUEyzBMk7o395NNOF6TlEJ4JiYUHvZzSTkRQe
dgGCFYjN/1e8Br64KAVaYMEe2quc9MQpcnScYYumlYWAoA+6qbrbEqIspo1KyE/p
3YXmEP2t7jfggR4uk4RJnjb+RprWi1b9rz6fguAitz3wTALUDNrSFTyZG0+1rdcN
u3H2xpUYJZoNN/gdJoqneQ==
###_VIRTUALSAFE_CHANGE_TRACKING_END_### '
./tools/packager/jpackager create-image \
    --verbose \
    --echo-mode \
    --input libs \
    --main-jar launcher-${BUILD_VERSION}.jar  \
    --class org.cryptomator.launcher.Cryptomator \
    --jvm-args "-Dcryptomator.logDir=\"~/.VirtualSAFE\"" \
    --jvm-args "-Dcryptomator.settingsPath=\"~/.VirtualSAFE/settings.json\"" \
    --jvm-args "-Dcryptomator.ipcPortPath=\"~/.VirtualSAFE/ipcPort.bin\"" \
    --jvm-args "-Dcryptomator.mountPointsDir=\"/Volumes\"" \
    --jvm-args "-Xss2m" \
    --jvm-args "-Xmx512m" \
    --jvm-args "-Xdock:name=VirtualSAFE" \
    --output app \
    --identifier cloud.virtualsafe \
    --name VirtualSAFE \
    --version ${BUILD_VERSION} \
    --module-path ${JAVA_HOME}/jmods\
    --add-modules java.base,java.logging,java.xml,java.sql,java.management,java.security.sasl,java.naming,java.datatransfer,java.security.jgss,java.rmi,java.scripting,java.prefs,java.desktop,jdk.unsupported \
    --strip-native-commands

# adjust .app
: ' ###_VIRTUALSAFE_CHANGE_TRACKING_START_###
U2FsdGVkX198wTAyIVSVLIEy45Cxnlf/ZFFzDScdR6dBITnyAuvwpC74VXNeBi/b
gvw6Ryi15IDgTVXpl0XlQIXyJ8sGyNXdOHr3UUL+UKVePsai/DUCyOg9ZhLGF3At
jsPUvdTzIyH5VEwL4X8L2n8sOPRQJHwR+f0SQyhXIxE/m4Qu2Y1kVUmFMWFXOK7A
/6nbvVCRdCKkvFA2Xq2odNl+H4lYusOV6ADCOAMzj+SDvYPJQFlYO1RT0jS6F0Oq
Kg0bAVPKkLsKsgPJOPKqf4S63lJkx3TnaEtGikL1hoJCyZCMU87sLhNpIzuB8L6f
D9tRnbfhbsjfVI6zpuVxBk8wPM1/DGJ9pgs4Rl+xAMOig6/Aj20bK/lS9FtOjPw5
HUnBYcj0Uv2paa2cb6FYiLgVkZeKbEDniYkpDDBy0BsiS+aeMYmyGbxBUjvk6AEg
yEYGwX5edhRgI4b6hKD2fRomYJsYGu7au98Sg+doVz0t4BZS2CHSIdE/KLvIBEOs
hvBtMR3AM+/9LwoFU3vMHt/OUq+sECOKP7swF4Hx77Aj3ffV7fulr8Xh8fcPQ9VC
ZYlSWsebokT7yhJf+4Avx6EaYLfWG2f4STEJt0WfjzQCFSjfyZ5you2e2JjIhdQI
rtYiUErKBqKg4KpB0VUc+z4T8QRxdy8S6t4+DaJY1ldzWPMD8ImBQ7vJeEMv/dCZ
ZCmfKKSHH/3myUVi+l9170jX4g1D3X0AL+/hcV1dymkcxtY0khXyh/EyGguoU0Ub
ZCRv/kErLPlpp3JG0k8Korh5cR/G28QhRCpN7oGZFR4wcs8bz2lY6t8tmvcXQygu
Jsv86dM4wIsQAK4wncpl/fH5lNl2fU+1xHAZJZR9ar1W3PU57ptkWXvwJTXdaTWq
###_VIRTUALSAFE_CHANGE_TRACKING_END_### '
cp resources/app/Info.plist app/VirtualSAFE.app/Contents/
cp resources/app/VirtualSAFE.icns app/VirtualSAFE.app/Contents/Resources/
cp resources/app/VirtualSAFE-Vault.icns app/VirtualSAFE.app/Contents/Resources/
cp resources/app/VolumeIcon.icns app/VirtualSAFE.app/Contents/Resources/
cp resources/app/_.VolumeIcon.icns app/VirtualSAFE.app/Contents/Resources/
cp resources/app/_. app/VirtualSAFE.app/Contents/Resources/
cp resources/app/libMacFunctions.dylib app/VirtualSAFE.app/Contents/Java/
sed -i '' "s|###BUILD_VERSION###|${VSAFEVERSION}|g" app/VirtualSAFE.app/Contents/Info.plist
sed -i '' "s|###COMMIT_COUNT###|${COMMIT_COUNT}|g" app/VirtualSAFE.app/Contents/Info.plist

: ' ###_VIRTUALSAFE_CHANGE_TRACKING_START_###
U2FsdGVkX18Y7j1RadiJCyIpBaWfoeDss/jLU4DzP9bF1Xhjs00hoXybCFZhe5DY
zNHYenVTVM7kF4k5h+4cydr6sCs3askthYO3mmEGP+zdjLBz55WbJuAAcyrY0aGn
MZrVrgOxkryRtwRh5jdIv3s0c1EsCve75pSP0ZNv/VEoFVAhEj9pInxYA4xajoV5
cmuzfHVJxy6MMe1J1DFXJ9DGuh+5PMg11bq/Qdva4A1Vh2nwPy6e50TYNKuHOJT6
###_VIRTUALSAFE_CHANGE_TRACKING_END_### '

# codesign
: ' ###_VIRTUALSAFE_CHANGE_TRACKING_START_###
U2FsdGVkX1+iUVBU4zY3K0fy+8PGhzCGSdZL9LporDfilahIa+U+EiOMbxtv/z7f
laNed29NV96jQ9UNWApcfgucmEyGhe69yWXWKpgO29GDRZJzpMxiVdUedGUL9m75
JQbiOvFVfvQHe6rYHE+v+8unzUkPJbKlxUBDxcUrfqb8rDxcHS7dqXU0wgmUH3fY
Yq+0iJZ4DNy36lb1aA+DQI/6DrhYMsOgBGVeELTmdBo7L/BY+i4BXTG/oiWOD7Du
DjWP1reSa16h6/Zp+oAoZeHVYYkwMcZF6Lu0K81VAtDQT1m7W9nWY9DO6gDQxmHr
1miw0E4ZvllHKitsdmmcHWxJeCCI813pkt+Rvd8BXEcD5O2ws6evb0cW1aqKQaZh
8CEL4zLPZzUkvIhzZHQhWNJrcssBGOgGWWf4ubKaQEXGpP/hdrKETPoOzYlzKLyq
bDkWfpGnEh9M7y+sJwepLDsAMPHHwPS6YIllfqF+yQsT0aeDavho7Ajs8X4ufFy4
oKZB/8uKpbwyo5tSAu39PVCTKj/8ZsiROOJXJkhVC06+kstV1wh9rMZgm132UOe8
jo7XOXMuXPNsDaMolTV+y49I19pfh5TN+N0/amtk7435XD+wszHJolQ6f82J2uGA
+ivuQ/jOryl3qcz8Ig8OFYLK2MQSTS8aqySIgDFaRwY=
###_VIRTUALSAFE_CHANGE_TRACKING_END_### '
security unlock-keychain
codesign --force --deep --verbose=4 -s "e-Lock Corporation Sdn Bhd" app/VirtualSAFE.app
if [ $? -ne 0 ]; then
  echo >&2 "codesigning .app failed.";
  exit 1;
fi

: ' ###_VIRTUALSAFE_CHANGE_TRACKING_START_###
U2FsdGVkX18SRiGnRFipE4pONc92sLvN8TsOeuU+TPwX84ygOHEp9de2+jo3Ol8y
hHDUqf8mO0LNsM+VO7rROVhUzcFu/LBRHPshDgOCafs82Y40ssaNcGtGB2P4I1Y8
uVGzV1juKjqPL7Z9FFW67dTUw0sEibfr9fFV6AhNE3zBzhRICmNEjsmnISeyWBUM
08e+aO6OBHehhpn+58MFu1LHajWdOzMJ5bAmM769Wn3xx2KyRR3T7XSYlIQjVYei
8dGcJvDR06DPGSqZm6CbDZKWRq5tIRYpXo7Az1WFAqyxBfWiZEwoZARKyy/SxD00
+0oGEzq4Ifqun+jmsqxpRHqD8uLYgEwe7/pB+vPFSZb30zzVNVDtiSNezrYzfJJ7
129NVFz5Ku8Lz99QOfDiqS5V/oojU0Yba/y8f3qgJgQFetHiiKQ95AMArOOQKqBJ
/wiGY/25bsSFXXXm0bnF+0J8oUE9B6uJWdm3vrkL4g077Ann0HNNa3WxhZU8jV8y
WODSTKYCyH/xTzI+z6vJc1ZLU5nXc0z9kL28kFOJFGlR2PyyoGHLzca1lzH+vcxx
ztHwBwy2AOQVlTUvNSrINK9unwksIrwjkZKnsSkEGRBiEru9esQu8+FD3A78nJYb
sP6WfJ9WHGpeWGjPUTHRJflk1JKPaQwVmOlGU1csZZPIo7XIRIwerGMqRYANTTKv
VWhqbN7Yf9mhQC2cRR/KDosiZWds808Tcfz+xHTi3xtlbU5bQ3CzDIZMB0BhIyO+
hdtlsIgA9FlwBAPIVmPjRdYAAAYzdhZuZxBXFTGzQ7H8m36LsNBYmQ2NIPOk6CkX
0sipT5FJpSz1CxAcSWl1HUxtQ2zXJbVSKXV7rLFC8E6moLB4+YfJd/hOcIS23ClO
QrLnQdWDEPZ2gY34dlH0lQVkxYrCXZ6exrJl5t59ilXSxc5FGPHu1iyI2X27HBb1
###_VIRTUALSAFE_CHANGE_TRACKING_END_### '
