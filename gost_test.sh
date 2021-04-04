#!/bin/ash

test_method='aes-128-ctr aes-128-cfb aes-256-ctr aes-256-cfb chacha20 chacha20-ietf rc4-md5 AEAD_AES_128_GCM AEAD_AES_256_GCM AEAD_CHACHA20_POLY1305'

gen_img_file(){
	dd if=/dev/zero of=/www/test.img bs=1M count=0 seek=300
}

clean_all(){
	rm -f /www/test.img $PWD/*curl_info
}

main(){
	set -x
	gen_img_file
	for method in $test_method
	do
		gost -L=ss://$method:password@:8338 >/dev/null 2>&1 &
		gost -L=socks5://:1080 -F=ss://$method:password@127.0.0.1:8338?nodelay=true >/dev/null 2>&1 &
		sleep 5s
		curl --socks5 127.0.0.1 127.0.0.1/test.img -o /dev/null 2>&1 | tee $PWD/${method}_curl_info
		killall gost
	done
	set +x
	echo
	echo -----------------nmsl friendlyarm -----------------
	for method in $test_method
	do
		echo "          Method $method speed: `cat ${method}_curl_info |grep '100'|awk -F ' ' '{print $(NF-5)}'`"
	done
	echo -----------------nmsl friendlyarm -----------------
	echo
	set -x
	clean_all
}

main