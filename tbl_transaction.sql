/****** Object:  Table [dbo].[tbl_transaction]    Script Date: 11/30/2014 11:07:46 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tbl_transaction]') AND type in (N'U'))
DROP TABLE [dbo].[tbl_transaction]
GO
/****** Object:  Table [dbo].[tbl_transaction]    Script Date: 11/30/2014 11:07:46 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [dbo].[tbl_transaction](
	[sno] [int] IDENTITY(1,1) NOT NULL,
	[txn_id] [varchar](30) NULL,
	[txn_source] [varchar](30) NULL,
	[user_login_id] [varchar](50) NULL,
	[sender_name] [varchar](100) NULL,
	[beneficiary_name] [varchar](50) NULL,
	[beneficiary_id] [varchar](30) NULL,
	[beneficiary_address] [varchar](50) NULL,
	[beneficiary_contact] [varchar](30) NULL,
	[payment_mode] [varchar](30) NULL,
	[bank_id] [varchar](30) NULL,
	[bank_name] [varchar](50) NULL,
	[bank_branch_name] [varchar](50) NULL,
	[bank_account_no] [varchar](30) NULL,
	[collect_amt] [money] NULL,
	[collect_ccy] [varchar](30) NULL,
	[exRate] [money] NULL,
	[exRate_process_id] [varchar](100) NULL,
	[payAmount] [money] NULL,
	[payout_ccy] [varchar](30) NULL,
	[Scharge] [money] NULL,
	[transStatus] [varchar](30) NULL,
	[Status] [varchar](30) NULL,
	[reward_points] [int] NULL,
	[token_id] [varchar](30) NULL,
	[token_expire_ts] [datetime] NULL,
	[token_expire_extended_by] [varchar](30)NULL,
	[refno] [varchar](30) NULL,
	[create_ts] [datetime] NULL,
	[create_by] [varchar](30) NULL,
	[update_ts] [datetime] NULL,
	[update_by] [varchar](30) NULL,
	[confirmDate] [datetime] NULL,
	[confirm_by] [varchar](100) NULL,
	[paid_date] [datetime] NULL,
	primary key ([sno])
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO


