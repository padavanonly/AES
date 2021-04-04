#!/bin/ash

test_method='aes-128-ctr aes-128-cfb aes-128-gcm aes-256-ctr aes-256-cfb aes-256-gcm chacha20 chacha20-poly1305'

main(){
	set -x
	for method in $test_method
	do
		openssl speed -evp $method 2>&1 | tee $PWD/${method}_openssl_info
	done
	set +x
	echo
	echo -----------------nmsl friendlyarm -----------------
	for method in $test_method
	do
		echo "          Method $method mark: `cat ${method}_openssl_info |grep "$method"|awk '{print $NF}'|sed -n '7p'`"
	done
	echo -----------------nmsl friendlyarm -----------------
	echo
	set -x
	rm -f $PWD/*_openssl_info
}

main