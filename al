
#Colors vars
green_color="\033[1;32m"
green_color_title="\033[0;32m"
red_color="\033[1;31m"
red_color_slim="\033[0;031m"
blue_color="\033[1;34m"
cyan_color="\033[1;36m"
brown_color="\033[0;33m"
yellow_color="\033[1;33m"
pink_color="\033[1;35m"
white_color="\e[1;97m"
normal_color="\e[1;0m"
#other var
com="$@"
lib="/data/data/com.termux/files/usr/lib/allib"

function last_echo() {
        echo -e "${2}$*${normal_color}"
}

function echo_green() {
	last_echo "${1}" "${green_color}"
}

function echo_blue() {
	last_echo "${1}" "${blue_color}"
}

function echo_yellow() {
	last_echo "${1}" "${yellow_color}"
}

function echo_red() {
	last_echo "${1}" "${red_color}"
}

function echo_red_slim() {
	last_echo "${1}" "${red_color_slim}"
}

function echo_green_title() {
	last_echo "${1}" "${green_color_title}"
}

function echo_pink() {
	last_echo "${1}" "${pink_color}"
}

function echo_cyan() {
	last_echo "${1}" "${cyan_color}"
}

function echo_brown() {
	last_echo "${1}" "${brown_color}"
}

function echo_white() {
	last_echo "${1}" "${white_color}"
}

function apkkey() {
    read -p "tes/build/compile? t/b/c: " aksi

    if [ "$aksi" = "b" ]; then
       read -p "nama project: " nama
       read -p "nama paket com/tes: " paket
       read -p "use object code y/n: " usejni
       mkdir -p "$nama/src/$paket"
       mkdir -p "$nama/assets"
       mkdir -p "$nama/bin"
       echo_pink "project $nama dibuat"

       if [ "$usejni" = "y" ]; then
           cp -R "$lib/build/jni" "$nama"
       fi
       cp -R "$lib/build/res" "$nama"
       cp -R "$lib/build/AndroidManifest.xml" "$nama"
       cp -R "$lib/build/MainActivity.java" "$nama/src/$paket"
    elif [ "$aksi" = "t" ]; then
       read -p "nama java(tanpa format): " nama
       echo_green "Compiling..."
       ecj "$nama".java
       echo_yellow "Dexing..."
       dx --dex --output="$nama".dex "$nama".class
       echo_yellow "Running..."
       dalvikvm -cp "$nama".dex "$nama"

    elif [ "$aksi" = "c" ]; then
       ls;echo;read -p "nama project: " nama
       echo_green `cat "$nama/"AndroidManifest.xml | grep package`
       echo
       read -p "nama paket: " paket;cd "$nama"

       echo_yellow "[+] Building R.java"
       aapt package -f -m -J src/ -M AndroidManifest.xml -S res/ -I $lib/android.jar
       rm -r bin/*

       clagi="y"
       while [ $clagi = "y" ]; do
            read -p "[+] compile y/n: " compile
            if [ "$compile" = "y" ]; then
                 echo_green "[+] Compiling..."
                 #ecj -d ./bin -verbose -Xbootclasspath/p:$PREFIX/share/java/android.jar -sourcepath ./src/ $(find ./src/ -type f -name \*.java)
                 javac -d bin -source 1.7 -target 1.7 -classpath src -bootclasspath ~/../usr/lib/allib/android.jar src/$paket/*.java
            else
                 clagi="n"
            fi
       done

       cclagi="y"
       while [ $cclagi = "y" ]; do
            if [ -d jni ]; then
                 read -p "[+] jni compile y/n: " jnicompile
            else
                 cclagi="n"
            fi
            if [ "$jnicompile" = "y" ]; then
                 echo_green "[+] Building C code"
                 clang -fpic -ffunction-sections -funwind-tables -fstack-protector-strong -Wno-invalid-command-line-argument -Wno-unused-command-line-argument -fno-integrated-as  -target armv5te-none-linux-androideabi -march=armv5te -mtune=xscale -msoft-float -mthumb -Os -g -DNDEBUG -fomit-frame-pointer -fno-strict-aliasing -O0 -UNDEBUG -marm -fno-omit-frame-pointer -Ijni -DANDROID  -Wa,--noexecstack -Wformat -Werror=format-security -I/data/data/com.termux/files/usr/include -c  jni/hello-jni.c -o ./hello-jni.o
                 mkdir -p lib/armeabi
                 clang -Wl,-soname,libhello-jni.so -shared ./hello-jni.o -lgcc -target armv5te-none-linux-androideabi  -Wl,--no-undefined -Wl,-z,noexecstack -Wl,-z,relro -Wl,-z,now   -lc -lm -o lib/armeabi/libhello-jni.so
            else
                 cclagi="n"
            fi
       done

       echo_blue "[+] Dexing -->> ";dx --dex --output=bin/classes.dex bin
       echo_blue "[+] Build apk -->> ";aapt package -f -m -F bin/out.apk -A assets -M AndroidManifest.xml -S res -I $lib/android.jar
       cp bin/classes.dex .

       if [ "$usejni" = "y" ]; then
             echo_blue "[+] Build C object -->> "
             aapt add bin/out.apk classes.dex lib/armeabi/libhello-jni.so
       else
             aapt add bin/out.apk classes.dex
       fi

       echo_yellow "[+] Signing apk"
       apksigner -p android release.keystore bin/out.apk bin/out-sign.apk
       echo
       echo_yellow "###### SUKSES ######"
       rm release.keystore
       rm classes.dex
       if [ "$usejni" = y ]; then
              rm -r lib
              rm hello-jni.o
       fi
       echo

    else
       echo_red "[!] input apkkey salah"
    fi
}

function git_manager() {
    read -p "upload/clone? u/c: " git_m
    echo_pink "$git_m"

    if [ "$git_m" = "u" ]; then
        git init
        git add .
        read -p "[+]  Masukan commit: " comit
        git commit -m "$comit"
        read -p "[+]  Masukan http: " http
        git remote add origin "$http"
        git push -f origin master

    elif [ "$git_m" = "c" ]; then
        read -p "[+]  Masukan link: " git_url
        pwd
        git clone "$git_url"
    else
        echo_red "[!]  input git salah"
    fi
}

function configure() {
    read -p "[+]  install web server y/n?" satu
    if [ "$satu" = "y" ]; then
        apt install php-apache
        echo
        read -p "[+] edit httpd.conf y/n?" dua
        if [ "$dua" = "y" ]; then
            cd "$PREFIX/etc/apache2/"
            ls;echo
            echo_green "Tambah ini:"
            echo_green "LoadModule php7_module /data/data/com.termux/file>"
            echo_green "<FilesMatch \.php$>"
            echo_green "    SetHandler application/x-httpd-php"
            echo_green "</FilesMatch>"
        fi
    fi

    read -p "[+]  install nano (editor text) y/n?" tiga
    if [ "$tiga" = "y" ]; then
        apt install nano
    fi

    read -p "[+]  install git (upload/download script) y/n?" empat
    if [ "$empat" = "y" ]; then
        apt install git
    fi

    read -p "[+]  install wget (download file) y/n?" lima
    if [ "$lima" = "y" ]; then
        apt install wget
    fi
}

echo_pink "$com"
echo
if [ "$com" = "git" ]; then
     git_manager
elif [ "$com" = "apkkey" ]; then
     apkkey
elif [ "$com" = "configure" ]; then
     configure
else
     echo
     echo_green_title "Welcome AI termux"
     echo_blue "[+]  configure"
     echo_blue "[+]  git"
     echo_blue "[+]  apkkey"
fi
echo
echo
