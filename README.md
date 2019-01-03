# masterpassword
Generate unique passwords from an encrypted supersecret

Masterpassword_generate.pl creates masterpassword.pl with an encrypted supersecret. This supersecret is used to generate unique passwords.

This can be used for administrators that share accounts. Instead of storing passwords the idea is to have a password that generates unique device (or domain) specific password. I.e device 1 get the password A and device 2 get the password B.

This is only a Perl proof of concept and it is a script that generates another encrypted script that contains a secret that can be used to generate hashes that can be used as unique passwords if you know the master password.

The masterpassword_generate.pl takes the parameters “key” and “supersecret” and creates the file masterpassword.pl that contains the encrypted “supersecret”. You then use masterpassword.pl with the key and a unique identifier (e.g. IP or domain) to create a unique password that is based on the supersecret.
You can create different masterpassword.pl that have the same supersecret but with different passwords and hand them out to different administrators. The weakness is that anyone with the right key can reveal the supersecret and if you have to change the supersecret you will then have to change all the unique passwords.
The resourceful could change the Twofish encryption to an asymmetric encryption.

Could maybe be used for smaller organizations. The supersecret password must be kept secret as you will have to change the passwords on all devices if it gets exposed. The supersecret should also be securely backuped (e.g. written on paper locked in a safe). The masterpassword.pl script should also be protected and only readable for users who will use it. Audit on file access could be used for extra protection.
