SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[ClemcoRpt_PackingSlipSp]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[ClemcoRpt_PackingSlipSp]
GO

-- ====================================================
-- Author:		 Watermark Solutions, LLC
--              Rob.Jeanquart
-- Create date: 09/22/2009
-- Description: Include RequestID#, then describe the project 
--              and changes to this object
--
-- Version History:
-- Date     ID                  Notes
-- -------- ------------------- ----------------------------------------- 
-- 09/22/09 Rob.Jeanquart       Initial Creations
-- ====================================================

/** TEST CODE -- --------------------------------------------------------------

DECLARE @RC int
BEGIN TRANSACTION
EXECUTE @RC = [dbo].[ClemcoRpt_PackingSlipSp] 
   'PJ00000003', 40 , 2
SELECT 'test results', @RC  as 'Return Code'
ROLLBACK TRANSACTION

TEST CODE -- -------------------------------------------------------------- **/

/* $Header: /ApplicationDB/Stored Procedures/ClemcoRpt_PackingSlipSp $  */
CREATE PROCEDURE [dbo].[ClemcoRpt_PackingSlipSp] (
  @ProjNum    ProjNumType
 ,@TaskNum    TaskNumType
 ,@Seq        ProjmatlSeqType
 )
AS
SET NOCOUNT ON

DECLARE    
   @Severity      INT
 , @Site          SiteType
 , @RowCount      INT
 , @Infobar       InfobarType 
 , @RefType       RefTypeIJPRType
 , @RefNum        JobPoReqNumType
 , @RefLine       SuffixPoReqLineType
SET @Severity = 0

SELECT @RefType = ref_type
     , @RefNum  = ref_num
     , @RefLine = ref_line_suf
FROM projmatl
WHERE proj_num = @ProjNum
 AND  task_num = @TaskNum
 AND  seq      = @Seq

IF NOT (@RefType = 'J' AND NOT @RefNum IS NULL) GOTO EXIT_RETURN

SELECT CAST(dbo.FmtJobSp(m.job,m.suffix) AS NVARCHAR(14)) as 'Job/Suffix'
, m.oper_num as 'Oper'
, o.wc as 'WC'
, m.sequence as 'Seq'
, m.item as 'Item'
, m.description as 'Description'
, m.matl_qty * (CASE m.units when 'L' THEN 1 ELSE j.qty_released END) as 'Qty Required'
, m.u_m as 'UM'
, m.qty_issued as 'Qty Issued'
, m.uf_ClemcoTruck as 'Truck'
, m.uf_ClemcoSkid as 'Skid'
, m.uf_ClemcoBox as 'Box'

FROM jobmatl m
JOIN job j ON j.job = m.job and j.suffix = m.suffix 
JOIN jobroute o ON o.job = m.job and o.suffix = m.suffix and o.oper_num = m.oper_num
WHERE m.job = @RefNum
 AND  m.suffix = @RefLine

 


EXIT_RETURN:

RETURN @Severity

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO