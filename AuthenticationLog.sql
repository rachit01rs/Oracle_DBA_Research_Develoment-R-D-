/****** Object:  Table [dbo].[AuthenticationLog]    Script Date: 12/02/2014 19:44:15 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[AuthenticationLog]') AND type in (N'U'))
DROP TABLE [dbo].[AuthenticationLog]
GO

/****** Object:  Table [dbo].[AuthenticationLog]    Script Date: 12/02/2014 19:44:15 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [dbo].[AuthenticationLog](
	[sno] [int] IDENTITY(1,1) NOT NULL,
	[UserName] [varchar](50) NULL,
	[AuthenticationLog] [varchar](150) NULL,
	[IMEI_Code] [varchar](50) NULL,
	[AuthenticationDate] [datetime] NULL,
	[LogoutDate] [datetime] NULL,
	[Status] [varchar](10) NULL,
	[transaction_id] [varchar](50) NULL,
 CONSTRAINT [PK_AuthenticationLog] PRIMARY KEY CLUSTERED 
(
	[sno] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO


