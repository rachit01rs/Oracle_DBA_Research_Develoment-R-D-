/****** Object:  Table [dbo].[tbl_image_info]    Script Date: 11/19/2014 11:57:23 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tbl_image_info]') AND type in (N'U'))
DROP TABLE [dbo].[tbl_image_info]
GO

/****** Object:  Table [dbo].[tbl_image_info]    Script Date: 11/19/2014 11:57:23 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [dbo].[tbl_image_info](
	[sno] [int] IDENTITY(1,1) NOT NULL,
	[img_id] [varchar](20) NULL,
	[userId] [varchar](30) NULL,
	[img_path] [varchar](255) NULL,
	[img_desc] [varchar](8000) NULL,
	[create_ts] [datetime] NULL,
	[isEnabled] [char](1) NULL,
PRIMARY KEY CLUSTERED 
(
	[sno] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO


