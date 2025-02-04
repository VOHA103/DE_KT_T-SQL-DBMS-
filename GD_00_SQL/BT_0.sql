﻿
----cAU 1 :TẠO DATABASE VÀ INSERT DU LIEU
use master
go

if exists(select *from sysdatabases where name='QL_DATHANG')
drop database QL_DATHANG
go



CREATE DATABASE QL_DATHANG
ON PRIMARY 
(
	Name=KS_primary,
	filename='E:\KT_KT_SQL\GD_00\KS_primary.mdf',
	size=5MB,
	maxsize=10MB,
	filegrowth=10%	
)

log on
(
	Name=KS_log,
	filename='E:\KT_KT_SQL\GD_00\KS_log.ldf',
	size=3MB,
	maxsize=5MB,
	filegrowth=15%	
)
go

USE QL_DATHANG
GO
------
CREATE TABLE KHACHHANG(
MAKH CHAR(10) PRIMARY KEY,
TENKH NVARCHAR(50),
DCHI NVARCHAR(50),
SDT CHAR(20)
)
GO

CREATE TABLE MATHANG(
MAMH CHAR(10) PRIMARY KEY,
TENMH NVARCHAR(50),
DVT CHAR(100),
DONGIA INT
)
GO


CREATE TABLE  DATHANG(

MADH CHAR(20) PRIMARY KEY,
NGAYDH DATE,
NGAYGIAODK DATE,
MAKH CHAR(10),
THANHTIEN INT,
TINHTRANG NVARCHAR(30),
CONSTRAINT PK_DH FOREIGN KEY (MAKH) REFERENCES KHACHHANG(MAKH)
)
GO

CREATE TABLE CTDH(

MADH CHAR(20),
MAMH CHAR(10),
SLDAT INT,
DGDAT INT,
CONSTRAINT PK_CTDH PRIMARY KEY(MADH,MAMH),
CONSTRAINT FK_STDH_DH FOREIGN KEY(MADH) REFERENCES DATHANG(MADH),
CONSTRAINT FK_STDH_MH FOREIGN KEY(MAMH) REFERENCES MATHANG(MAMH)


)
GO

SET DATEFORMAT DMY
INSERT INTO KHACHHANG VALUES('KH01',N'DUONG DONG DUY',N'TIEN GIANG','0376880903');
INSERT INTO KHACHHANG VALUES('KH02',N'HO DUC DUY',N'BINH DINH','0348770100');
INSERT INTO KHACHHANG VALUES('KH03',N'VO THI THU HA',N'BINH DINH','0328090646');
INSERT INTO KHACHHANG VALUES('KH04',N'NGO THANH HUYEN',N'QUANG BINH','0387388001');

INSERT INTO MATHANG VALUES('MH01',N'BANH GAO',N'CAI',120);
INSERT INTO MATHANG VALUES('MH02',N'NUO EP TAO',N'CHAI',170);
INSERT INTO MATHANG VALUES('MH03',N'KEO DEO',N'BICH',90);
INSERT INTO MATHANG VALUES('MH04',N'MI TOM CHUA CAY',N'THUNG',100);

SET DATEFORMAT DMY
INSERT INTO DATHANG VALUES('DH01','1/12/2021','5/12/2021','KH02',1500,N'HET');
INSERT INTO DATHANG VALUES('DH02','6/12/2021','9/12/2021','KH01',1800,N'CON');
INSERT INTO DATHANG VALUES('DH03','4/12/2021','5/12/2021','KH04',320,N'CON');
INSERT INTO DATHANG VALUES('DH04','8/12/2021','9/12/2021','KH03',10,'HET');

INSERT INTO CTDH VALUES('DH01','MH03',2,1674000);
INSERT INTO CTDH VALUES('DH04','MH02',1,104000);
INSERT INTO CTDH VALUES('DH03','MH04',3,189000);
INSERT INTO CTDH VALUES('DH02','MH01',4,18000);
GO
-----BAI LAM:
--2.A:VIẾT THỦ TỤC NHẬP VÀO MÃ ĐƠN HAGF,TRẢ VỀ TÊN,ĐỊA CHỈ VÀ SỐ ĐIỆN THOẠI CỦA KHÁCH ĐÃ ĐẶT
---HÀNG HÓ.VIẾT LỆNH GỌI THỰC HIỆN THỦ TỤC. 
CREATE PROC PS_CAU2A(@MADH CHAR(20))
AS

	BEGIN
		SELECT KH.TENKH,KH.SDT,KH.DCHI
		FROM KHACHHANG KH,DATHANG DH
		WHERE  DH.MADH=@MADH AND DH.MAKH=KH.MAKH
	END
GO

--GOI THU TUC THUCC THI
EXEC PS_CAU2A 'DH02'
--XOA THU TUC
DROP PROC PS_CAU2A
GO
--2.B:VIẾT HÀM NHẬP VÀO MÃ ĐƠN HÀNG,TRẢ VỀ BẢNG HỨA THÔNG TIN:
--MÃ MẶT HÀNG,TÊN MẶT HÀNG,SỐ LƯỢNG ĐẶT ,ĐƠN GIÁ ĐẶT HÀNG VÀ THÀNH TIỀN 
--CỦA CÁC MẶT HÀNG TRONG ĐƠN HÀNG ĐÓ.
--BIẾT THÀNH TIỀN ỦA MỖI HÀNG TRONG ĐƠN HÀNG =SỐ LƯỢNG ĐẶT * ĐƠN GIÁ ĐẶT.
--VIẾT LỆNH GỌI THỰC HIỆN HÀM.

CREATE FUNCTION FC_AU2B (@MADH CHAR(20))
RETURNS TABLE
AS
	
		RETURN (SELECT MH.MAMH,MH.TENMH,CT.SLDAT,CT.DGDAT,CT.SLDAT*CT.DGDAT AS TT
				FROM CTDH CT,MATHANG MH
				WHERE  CT.MADH=@MADH AND CT.MAMH=MH.MAMH
				)	
GO
---GOI HAM THUC THI
SELECT*FROM dbo.FC_AU2B ('DH01')

SELECT* FROM CTDH
SELECT* FROM MATHANG

--XOA HAM 	
DROP FUNCTION dbo.FC_AU2B 

--CAU 3:
--3.A:TẠI MỖI THỜI ĐIỂM TI(I>=1) SINH VIÊN TỰ THÊM 1 DÒNG DỮ LIỆU VÀO BẢNG KHACHHANG
------Back up:



USE QL_DATHANG
GO
--------------------
ALTER DATABASE QL_DATHANG
SET RECOVERY FULL
--t1:full backup,tham so WITH INIT cho phep ghi de len file hien tai
BACKUP DATABASE  QL_DATHANG 
TO DISK='E:\KT_KT_SQL\GD_00\QL_DATHANG_FULL.bak' 
WITH INIT
GO
--THEM 1 BANG GHI MOI
INSERT INTO KHACHHANG VALUES('KH08',N'HO DUC DUY',N'BINH DINH','0348770100');
GO
--T2:differential backup
BACKUP DATABASE QL_DATHANG 
 TO DISK='E:\KT_KT_SQL\GD_00\QL_DATHANG_DIFF.bak'
WITH INIT,DIFFERENTIAL
GO
--THEM 1 BAN GHI MOI THU 2
INSERT INTO KHACHHANG VALUES('KH09',N'HO DUC DUY',N'BINH DINH','0348770100');
GO
--T3:transaction log backup
--alter database QL_DATHANG set read_only with no_wait

BACKUP LOG QL_DATHANG 
TO DISK='E:\KT_KT_SQL\GD_00\QL_DATHANG_LOG.TRN' 
 WITH INIT 

GO
--THEM 1 BAN GHI THU 3
INSERT INTO KHACHHANG VALUES('KH010',N'HO DUC DUY',N'BINH DINH','0348770100');
GO
--T4:TRANSACTION LOG BACKUP LAN NUA
--KHONG COS THAM SO WITH INIT DE BO SUNG VAO BAN LOG TRUOC DO 
BACKUP LOG QL_DATHANG 
TO DISK=N'E:\KT_KT_SQL\GD_00\QL_DATHANG_LOG.TRN'
WITH NO_TRUNCATE
go
---T5:XAY RA SU CO
USE MASTER
GO
DROP DATABASE QL_DATHANG;

--3.B:VIẾT LỆNH KHÔI PHUC SDL KHI SỰ CỐ XẢY RA Ở THỜI ĐIỂM T5.



--BUOC 1: KHOI PHUC TU BANFULL BACKUP. THAM SO" WITH NORECOVERY" DE SAU MOI LENH 
RESTORE DATABASE QL_DATHANG 
FROM DISK='E:\KT_KT_SQL\GD_00\QL_DATHANG_FULL.bak' 
WITH REPLACE, NORECOVERY
GO
--BUOC 2: KHOI PHUC TU BANG DIDDERENTIAL BACKUP
RESTORE DATABASE QL_DATHANG 
FROM DISK='E:\KT_KT_SQL\GD_00\QL_DATHANG_DIFF.bak'
 WITH NORECOVERY
GO
--BUOC 3: KHOI PHUC TU CACS BAN TRANSACTION LOG BACKUP THEO TRINH TU THOI GIAN
RESTORE DATABASE QL_DATHANG 
FROM DISK='E:\KT_KT_SQL\GD_00\QL_DATHANG_LOG.TRN' 
WITH FILE=1, NORECOVERY

RESTORE DATABASE QL_DATHANG 
FROM DISK='E:\KT_KT_SQL\GD_00\QL_DATHANG_LOG.TRN' 
WITH FILE=2,RECOVERY,replace
GO
--KIEM TRA LAI SAU KHI KHOI PHUC
USE QL_DATHANG
GO
SELECT*FROM KHACHHANG
GO

---CAU 4 :PHAN QUYEN
--4.A:
sp_addlogin 'mai','123'
go
sp_addlogin 'dao','456'
go
sp_addlogin 'tho','789'
go
--4.b:
sp_adduser 'mai','mai'
go
sp_adduser 'dao','dao'
go
sp_adduser 'tho','tho'
go
--4.b:
--tao nhom quyen khachhang
sp_addrole 'KhachHang'
go
--phân quyền cho nhóm quyền khachhang xem ac mat hang
grant select
on MATHANG
to KhachHang
go
--tao nhom quyen nhanvien
sp_addrole 'NhaVien'
go
--phân quyền cho nhóm quyền NhaVien xem ,them,xoa,sua khach hang
grant select,insert,delete,update
on KHACHHANG
to NhaVien
go
--phân quyền cho nhóm quyền NhaVien xem ,them,xoa,sua DON DAT HANG (TABLE DATHANG,CTDH)
grant select,insert,delete,update
on DATHANG
to NhaVien
go
grant select,insert,delete,update
on CTDH
to NhaVien
go

---CAU 5:GIAO TAC THÊM MẶT HÀNG DƯỚI DẠNG STARSD PROCEDURE NHƯ SAU:
--INPUT:THOG TIN MẶT HÀNG MỚI ẦN THÊM
--OUTPUT:0--THEM THANH CONG.1-THEM KHONG THANH CONG
CREATE PROCEDURE CAU5 (@MAMH CHAR(10),@TENMH NVARCHAR(20),@DVT VARCHAR(10),@DONGIA INT,@CHECK INT OUT)
AS 
BEGIN
	IF( @DVT!=N'THUNG'OR @DVT!=N'CHAI' OR @DVT!=N'GOI' OR @DVT!=N'HOP')
	BEGIN
	PRINT '1'
	ROLLBACK TRAN
	END
	ELSE
	IF(@MAMH=NULL or @MAMH='' or @TENMH='' OR @TENMH=NULL)
		BEGIN
			PRINT '1'
			ROLLBACK TRAN
		END
	ELSE
		IF(@DONGIA<=0)
		BEGIN
			PRINT '1'
			ROLLBACK TRAN
		END
		ELSE
			BEGIN
				 IF((SELECT COUNT(*) FROM DBO.MATHANG WHERE MAMH=@MAMH OR TENMH=@TENMH and MAMH=@MAMH)>0)
					PRINT '1'
				 ELSE
					BEGIN
					 INSERT INTO DBO.MATHANG VALUES(@MAMH,@TENMH,@DVT,@DONGIA)
					 PRINT '0'
					END
			 END
END;
GO
--NỌI DUNG THAO TAC:
--KIEM TRA THONG TIN MÃ HÀNG VÀ TÊN HÀNG KHÔNG DC RỖNG VÀ DUY NHẤT.
--ĐƠN VỊ TÍNH CHỈ DC NHẬP 1 TRONG 4 GIÁ TRỊ SAU: THÙNG,CHAI,GÓI,HỘP.
--ĐƠN GIÁ PHẢI >0
--THÊM MẶT HÀNG MỚI.
declare @check int
EXEC CAU5 'TV','AAAAA',N'chai',0,@check out
print @check