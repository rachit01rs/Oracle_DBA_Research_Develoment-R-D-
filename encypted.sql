


--USING ENCRYPTION 
CREATE TABLE USERS (
   user_id       NUMBER,
   user_name     VARCHAR2(30),
   user_location VARCHAR2(30),
   password     VARCHAR2(200),
   CONSTRAINT users_pk PRIMARY KEY (user_id) 
);

insert into USERS
values (1,'RABINRS','GRK','adminrabin1');

insert into USERS
values (2,'RAJANK','BAG','rajan01');

insert into USERS
values (3,'BIMALP','MRD','bimal789');

commit;

exit;
select * from USERS;


-- procedure of encyption 
CREATE OR REPLACE PACKAGE enc_dec
AS
   FUNCTION encrypt (p_plainText VARCHAR2) RETURN RAW DETERMINISTIC;
   FUNCTION decrypt (p_encryptedText RAW) RETURN VARCHAR2 DETERMINISTIC;
END;
/

CREATE OR REPLACE PACKAGE BODY enc_dec
AS
     encryption_type    PLS_INTEGER := DBMS_CRYPTO.ENCRYPT_DES
                                     + DBMS_CRYPTO.CHAIN_CBC
                                     + DBMS_CRYPTO.PAD_PKCS5;
     /*
       ENCRYPT_DES is the encryption algorithem. Data Encryption Standard. Block cipher. 
       Uses key length of 56 bits.
       CHAIN_CBC Cipher Block Chaining. Plaintext is XORed with the previous ciphertext 
       block before it is encrypted.
       PAD_PKCS5 Provides padding which complies with the PKCS #5: Password-Based 
       Cryptography Standard
     */
     encryption_key     RAW (32) := UTL_RAW.cast_to_raw('MyEncryptionKey');
     -- The encryption key for DES algorithem, should be 8 bytes or more.

     FUNCTION encrypt (p_plainText VARCHAR2) RETURN RAW DETERMINISTIC
     IS
        encrypted_raw      RAW (2000);
     BEGIN
        encrypted_raw := DBMS_CRYPTO.ENCRYPT
        (
           src => UTL_RAW.CAST_TO_RAW (p_plainText),
           typ => encryption_type,
           key => encryption_key
        );
       RETURN encrypted_raw;
     END encrypt;
     FUNCTION decrypt (p_encryptedText RAW) RETURN VARCHAR2 DETERMINISTIC
     IS
        decrypted_raw      RAW (2000);
     BEGIN
        decrypted_raw := DBMS_CRYPTO.DECRYPT
        (
            src => p_encryptedText,
            typ => encryption_type,
            key => encryption_key
        );
        RETURN (UTL_RAW.CAST_TO_VARCHAR2 (decrypted_raw));
     END decrypt;
END;
/

grant execute on enc_dec to system;
create public synonym enc_dec for sys.enc_dec;

exit;


select enc_dec.encrypt('adminrabin1') encrypted 
from dual;
select enc_dec.decrypt('76F96F32E0D91D1E43EDECB44921B9EE') decrypted
from dual;

update USERS set password=ENC_DEC.ENCRYPT(password);
commit;
exit;
insert into users  values (4,'SCOTT','TEXAS',enc_dec.encrypt('scott456'));
insert into users values(5,'SANTOSHD','NWL',enc_dec.encrypt('santosh01'));
insert into users values(6,'RACHIN','PRK',enc_dec.encrypt('rachin01sth'));
commit;
exit;
select USER_NAME ,                                              
       enc_dec.decrypt (password) decrypted_password,
       password encrypted_password
from users;
GRANT select on users to system;
commit;
exit;
grant select on users to hr;


select * from users;
select ENC_DEC.DECRYPT('6D58091685D8EFAE') decrypted from dual 
update users set password=enc_dec.encrypt('rajankarki32r') where USER_ID=2;
-- column alias and concatination operator
select *  from scott.emp;
select ENAME as Name,COMM as commission   from scott.emp;
select ENAME "Name",sal*12 "Annual_Sal" from scott.emp;



create or replace PACKAGE AUTHENTICATION_PKG
AS

  --Our custom authentication function
  FUNCTION authenticate_users(user_id IN users.user_name%TYPE, p_password_in IN USERs.password%TYPE)
      RETURN BOOLEAN;
  END AUTHENTICATION_PKG; 