/******************************
** File: Buildscript_1.00.002.sql
** Name: Buildscript_1.00.002
** Auth: McNiel Viray
** Date: 05 April 2017
**************************
** Change History
**************************
** Create initial data for Site, Campaign, LoB
*******************************/
USE WFMPCP
GO

DECLARE @DateNow DATETIME = GETDATE()
	,@SiteID BIGINT
	,@CampaignID BIGINT

PRINT 'Create Site for CHR'

INSERT INTO [Site]([Name],Code,[Description],CreatedBy,DateCreated)
VALUES('Chateau Ridiculous','CHR','Taskus Anonas QC','McNiel Viray', @DateNow)

SELECT @SiteID = SCOPE_IDENTITY()

	PRINT 'Create Campaign for CHR - 1. UBER'

	INSERT INTO Campaign(SiteID,[Name],Code,[Description],CreatedBy,DateCreated)
	VALUES(@SiteID,'UBER','UberCHR','CHR Uber campaign','McNiel Viray',@DateNow)

	SELECT @CampaignID = SCOPE_IDENTITY()

		PRINT 'Create LoB for UBER CHR'

		INSERT INTO LoB(CampaignID,[Name],Code,[Description],CreatedBy,DateCreated)
		VALUES(@CampaignID,'US EATS Phone','USEATSPhone','US EATS Phone','McNiel Viray',@DateNow)

		INSERT INTO LoB(CampaignID,[Name],Code,[Description],CreatedBy,DateCreated)
		VALUES(@CampaignID,'EMEA EATS Phone','EMEAEATSPhone','EMEA EATS Phone','McNiel Viray',@DateNow)

		INSERT INTO LoB(CampaignID,[Name],Code,[Description],CreatedBy,DateCreated)
		VALUES(@CampaignID,'EMEA EATS Rider Email','EMEAEATSRiderEmail','EMEA EATS Rider Email','McNiel Viray',@DateNow)

		INSERT INTO LoB(CampaignID,[Name],Code,[Description],CreatedBy,DateCreated)
		VALUES(@CampaignID,'EMEA EATS Driver Email','EMEAEATSDriverEmail','EMEA EATS Driver Email','McNiel Viray',@DateNow)

		INSERT INTO LoB(CampaignID,[Name],Code,[Description],CreatedBy,DateCreated)
		VALUES(@CampaignID,'US EATS Rider Email','USEATSRiderEmail','US EATS Rider Email','McNiel Viray',@DateNow)

		INSERT INTO LoB(CampaignID,[Name],Code,[Description],CreatedBy,DateCreated)
		VALUES(@CampaignID,'US EATS Driver Email','USEATSDriverEmail','US EATS Driver Email','McNiel Viray',@DateNow)

		INSERT INTO LoB(CampaignID,[Name],Code,[Description],CreatedBy,DateCreated)
		VALUES(@CampaignID,'US Driver T1_Driver Account','USDriverT1DriverAccount','US Driver T1_Driver Account','McNiel Viray',@DateNow)

		INSERT INTO LoB(CampaignID,[Name],Code,[Description],CreatedBy,DateCreated)
		VALUES(@CampaignID,'UKI Rider T1','UKIRiderT1','UKI Rider T1','McNiel Viray',@DateNow)

		INSERT INTO LoB(CampaignID,[Name],Code,[Description],CreatedBy,DateCreated)
		VALUES(@CampaignID,'UKI Driver T1','UKIDriverT1','UKI Driver T1','McNiel Viray',@DateNow)

		INSERT INTO LoB(CampaignID,[Name],Code,[Description],CreatedBy,DateCreated)
		VALUES(@CampaignID,'UKI Rider T2','UKIRiderT2','UKI Rider T2','McNiel Viray',@DateNow)

		INSERT INTO LoB(CampaignID,[Name],Code,[Description],CreatedBy,DateCreated)
		VALUES(@CampaignID,'UKI Driver T2','UKIDriverT2','UKI Driver T2','McNiel Viray',@DateNow)

		INSERT INTO LoB(CampaignID,[Name],Code,[Description],CreatedBy,DateCreated)
		VALUES(@CampaignID,'MENA Rider T1','MENARiderT1','MENA Rider T1','McNiel Viray',@DateNow)

		INSERT INTO LoB(CampaignID,[Name],Code,[Description],CreatedBy,DateCreated)
		VALUES(@CampaignID,'SSA Rider T1','SSARiderT1','SSA Rider T1','McNiel Viray',@DateNow)

		INSERT INTO LoB(CampaignID,[Name],Code,[Description],CreatedBy,DateCreated)
		VALUES(@CampaignID,'SSA Rider T2','SSARiderT2','SSA Rider T2','McNiel Viray',@DateNow)

		INSERT INTO LoB(CampaignID,[Name],Code,[Description],CreatedBy,DateCreated)
		VALUES(@CampaignID,'ANZ Rider T1','ANZRiderT1','ANZ Rider T1','McNiel Viray',@DateNow)

		INSERT INTO LoB(CampaignID,[Name],Code,[Description],CreatedBy,DateCreated)
		VALUES(@CampaignID,'ANZ Driver T1','ANZDriverT1','ANZ Driver T1','McNiel Viray',@DateNow)

		INSERT INTO LoB(CampaignID,[Name],Code,[Description],CreatedBy,DateCreated)
		VALUES(@CampaignID,'ANZ Rider/Driver T2','ANZRiderDriverT2','ANZ Rider/Driver T2','McNiel Viray',@DateNow)

		INSERT INTO LoB(CampaignID,[Name],Code,[Description],CreatedBy,DateCreated)
		VALUES(@CampaignID,'ANZDocsApprover','ANZ Docs Approver','ANZ Docs Approver','McNiel Viray',@DateNow)

		INSERT INTO LoB(CampaignID,[Name],Code,[Description],CreatedBy,DateCreated)
		VALUES(@CampaignID,'SENA Driver Account','SENADriverAccount','SENA Driver Account','McNiel Viray',@DateNow)

		INSERT INTO LoB(CampaignID,[Name],Code,[Description],CreatedBy,DateCreated)
		VALUES(@CampaignID,'SENA Driver Trip Questions','SENADriverTripQuestions','SENA Driver Trip Questions','McNiel Viray',@DateNow)

		INSERT INTO LoB(CampaignID,[Name],Code,[Description],CreatedBy,DateCreated)
		VALUES(@CampaignID,'SENA Rider Account','SENARiderAccount','SENA Rider Account','McNiel Viray',@DateNow)

		INSERT INTO LoB(CampaignID,[Name],Code,[Description],CreatedBy,DateCreated)
		VALUES(@CampaignID,'SENA Driver Voice Support - PH','SENADriverVoiceSupportPH','SENA Driver Voice Support - PH','McNiel Viray',@DateNow)

		INSERT INTO LoB(CampaignID,[Name],Code,[Description],CreatedBy,DateCreated)
		VALUES(@CampaignID,'SENA Driver Voice Support - LCR','SENADriverVoiceSupportLCR','SENA Driver Voice Support - LCR','McNiel Viray',@DateNow)

		INSERT INTO LoB(CampaignID,[Name],Code,[Description],CreatedBy,DateCreated)
		VALUES(@CampaignID,'SENA Driver Voice Support - SG','SENADriverVoiceSupportSG','SENA Driver Voice Support - SG','McNiel Viray',@DateNow)

		INSERT INTO LoB(CampaignID,[Name],Code,[Description],CreatedBy,DateCreated)
		VALUES(@CampaignID,'SENA Driver Voice Support - MY','SENADriverVoiceSupportMY','SENA Driver Voice Support - MY','McNiel Viray',@DateNow)

		INSERT INTO LoB(CampaignID,[Name],Code,[Description],CreatedBy,DateCreated)
		VALUES(@CampaignID,'US IIT','US IIT','US IIT','McNiel Viray',@DateNow)

		INSERT INTO LoB(CampaignID,[Name],Code,[Description],CreatedBy,DateCreated)
		VALUES(@CampaignID,'ANZ IIT','ANZ IIT','ANZ IIT','McNiel Viray',@DateNow)

		INSERT INTO LoB(CampaignID,[Name],Code,[Description],CreatedBy,DateCreated)
		VALUES(@CampaignID,'SENA IIT','SENA IIT','SENA IIT','McNiel Viray',@DateNow)

		INSERT INTO LoB(CampaignID,[Name],Code,[Description],CreatedBy,DateCreated)
		VALUES(@CampaignID,'SENA ECR','SENA ECR','SENA ECR','McNiel Viray',@DateNow)


	PRINT 'Create Campaign for CHR - 2. ADOREME'
	INSERT INTO Campaign(SiteID,[Name],Code,[Description],CreatedBy,DateCreated)
	VALUES(@SiteID,'ADORME','ADOREMECHR','ADOREME','McNiel Viray',@DateNow)

	SELECT @CampaignID = SCOPE_IDENTITY()
		
		PRINT 'Create LoB For CHR Adorme'
		INSERT INTO LoB(CampaignID,[Name],Code,[Description],CreatedBy,DateCreated)
		VALUES(@CampaignID,'Phone','APhone','Phone','McNiel Viray',@DateNow)

		INSERT INTO LoB(CampaignID,[Name],Code,[Description],CreatedBy,DateCreated)
		VALUES(@CampaignID,'Email','AEmail','Email','McNiel Viray',@DateNow)

		INSERT INTO LoB(CampaignID,[Name],Code,[Description],CreatedBy,DateCreated)
		VALUES(@CampaignID,'Chat','AChat','Chat','McNiel Viray',@DateNow)

	PRINT 'Create Campaign for CHR - 3. TURO'
	INSERT INTO Campaign(SiteID,[Name],Code,[Description],CreatedBy,DateCreated)
	VALUES(@SiteID,'TURO','TUROCHR','TURO','McNiel Viray',@DateNow)

	SELECT @CampaignID = SCOPE_IDENTITY()
		
		PRINT 'Create LoB For CHR TURO'
		INSERT INTO LoB(CampaignID,[Name],Code,[Description],CreatedBy,DateCreated)
		VALUES(@CampaignID,'General Line','General Line','General Line','McNiel Viray',@DateNow)

		INSERT INTO LoB(CampaignID,[Name],Code,[Description],CreatedBy,DateCreated)
		VALUES(@CampaignID,'Emergency Line and Tier 3','Emergency Line and Tier 3','Emergency Line and Tier 3','McNiel Viray',@DateNow)

		INSERT INTO LoB(CampaignID,[Name],Code,[Description],CreatedBy,DateCreated)
		VALUES(@CampaignID,'Verifications','Verifications','Verifications','McNiel Viray',@DateNow)

PRINT 'Create Site for LBL'

INSERT INTO [Site]([Name],Code,[Description],CreatedBy,DateCreated)
VALUES('LizardBear Lair','LBL','Taskus BGC','McNiel Viray', @DateNow)

SELECT @SiteID = SCOPE_IDENTITY()

	PRINT 'Create Campaign for LBL - 1. Nimble'
	INSERT INTO Campaign(SiteID,[Name],Code,[Description],CreatedBy,DateCreated)
	VALUES(@SiteID,'NIMBLE','NIMBLELBL','Nimble LBL','McNiel Viray',@DateNow)

	SELECT @CampaignID = SCOPE_IDENTITY()
		INSERT INTO LoB(CampaignID,[Name],Code,[Description],CreatedBy,DateCreated)
		VALUES(@CampaignID,'Phone','NIMBLEPHONE','Nimble Phone','McNiel Viray',@DateNow)

		INSERT INTO LoB(CampaignID,[Name],Code,[Description],CreatedBy,DateCreated)
		VALUES(@CampaignID,'Email','NIMBLEEMAIL','Nimble Email','McNiel Viray',@DateNow)
		

	PRINT 'Create Campaign for LBL - 2. Box'
	INSERT INTO Campaign(SiteID,[Name],Code,[Description],CreatedBy,DateCreated)
	VALUES(@SiteID,'BOX','BOXLBL','BOX LBL','McNiel Viray',@DateNow)

	SELECT @CampaignID = SCOPE_IDENTITY()
		INSERT INTO LoB(CampaignID,[Name],Code,[Description],CreatedBy,DateCreated)
		VALUES(@CampaignID,'Billing','BOXBILLING','Box Billing','McNiel Viray',@DateNow)

		INSERT INTO LoB(CampaignID,[Name],Code,[Description],CreatedBy,DateCreated)
		VALUES(@CampaignID,'Tech','BOXTECH','Box tech','McNiel Viray',@DateNow)

		INSERT INTO LoB(CampaignID,[Name],Code,[Description],CreatedBy,DateCreated)
		VALUES(@CampaignID,'Sales','BOXSALES','Box sales','McNiel Viray',@DateNow)



	PRINT 'Create Campaign for LBL - 3. Tile'
	INSERT INTO Campaign(SiteID,[Name],Code,[Description],CreatedBy,DateCreated)
	VALUES(@SiteID,'TILE','TILELBL','Tile Lbl','McNiel Viray',@DateNow)

	SELECT @CampaignID = SCOPE_IDENTITY()
		INSERT INTO LoB(CampaignID,[Name],Code,[Description],CreatedBy,DateCreated)
		VALUES(@CampaignID,'Email','TILEEMAIL','Tile EMail','McNiel Viray',@DateNow)

		INSERT INTO LoB(CampaignID,[Name],Code,[Description],CreatedBy,DateCreated)
		VALUES(@CampaignID,'Chat','TILECHAT','Tile Chat','McNiel Viray',@DateNow)
		


	PRINT 'Create Campaign for LBL - 4. PostMates'
	INSERT INTO Campaign(SiteID,[Name],Code,[Description],CreatedBy,DateCreated)
	VALUES(@SiteID,'POSTMATES','PMLBL','PostMates LBL','McNiel Viray',@DateNow)

	SELECT @CampaignID = SCOPE_IDENTITY()
		INSERT INTO LoB(CampaignID,[Name],Code,[Description],CreatedBy,DateCreated)
		VALUES(@CampaignID,'Full Time','PMFULLTIME','Postmates full time employee','McNiel Viray',@DateNow)

		INSERT INTO LoB(CampaignID,[Name],Code,[Description],CreatedBy,DateCreated)
		VALUES(@CampaignID,'Part Time','PMPARTTIME','Postmates part time employee','McNiel Viray',@DateNow)



	PRINT 'Create Campaign for LBL - 5. SHOPIFY'
	INSERT INTO Campaign(SiteID,[Name],Code,[Description],CreatedBy,DateCreated)
	VALUES(@SiteID,'SHOPIFY','SHOPIFY','Shopify','McNiel Viray',@DateNow)

	SELECT @CampaignID = SCOPE_IDENTITY()
		INSERT INTO LoB(CampaignID,[Name],Code,[Description],CreatedBy,DateCreated)
		VALUES(@CampaignID,'Shopify','SHOPIFYLOB','Shopify lob','McNiel Viray',@DateNow)


PRINT 'Create Site for House Teamwork'

INSERT INTO [Site]([Name],Code,[Description],CreatedBy,DateCreated)
VALUES('House Teamwork','HTM','Taskus Pampanga','McNiel Viray', @DateNow)

SELECT @SiteID = SCOPE_IDENTITY()
	
	PRINT 'Create Campaign for HTM - 1. Doordash'
	INSERT INTO Campaign(SiteID,[Name],Code,[Description],CreatedBy,DateCreated)
	VALUES(@SiteID,'DOORDASH','DOORDAHSHTM','Doordash house teammate','McNiel Viray',@DateNow)

	SELECT @CampaignID = SCOPE_IDENTITY()
		INSERT INTO LoB(CampaignID,[Name],Code,[Description],CreatedBy,DateCreated)
		VALUES(@CampaignID,'Customer Support - Chat','DDCSCHTM','','McNiel Viray',@DateNow)
		INSERT INTO LoB(CampaignID,[Name],Code,[Description],CreatedBy,DateCreated)
		VALUES(@CampaignID,'Order Placer','DDOPTHM','Oder placer','McNiel Viray',@DateNow)


	PRINT 'Create Campaign for HTM - 2. HUDL'
	INSERT INTO Campaign(SiteID,[Name],Code,[Description],CreatedBy,DateCreated)
	VALUES(@SiteID,'HUDL','HUDLHTM','HUDL House Teammate','McNiel Viray',@DateNow)

	SELECT @CampaignID = SCOPE_IDENTITY()
		INSERT INTO LoB(CampaignID,[Name],Code,[Description],CreatedBy,DateCreated)
		VALUES(@CampaignID,'Football - Full Time','FBFTHTM','Football full time','McNiel Viray',@DateNow)
		INSERT INTO LoB(CampaignID,[Name],Code,[Description],CreatedBy,DateCreated)
		VALUES(@CampaignID,'Football - Part Time','FBPTHTM','Football part time','McNiel Viray',@DateNow)
		INSERT INTO LoB(CampaignID,[Name],Code,[Description],CreatedBy,DateCreated)
		VALUES(@CampaignID,'Basketball - Full Time','BBFTGTN','Basketball full time','McNiel Viray',@DateNow)



	PRINT 'Create Campaign for HTM - 3. Wish'
	INSERT INTO Campaign(SiteID,[Name],Code,[Description],CreatedBy,DateCreated)
	VALUES(@SiteID,'WISH','WHISHHTM','Wish HTM','McNiel Viray',@DateNow)

	SELECT @CampaignID = SCOPE_IDENTITY()
		INSERT INTO LoB(CampaignID,[Name],Code,[Description],CreatedBy,DateCreated)
		VALUES(@CampaignID,'Email','WISHEMAIL','Wish Email HTM','McNiel Viray',@DateNow)


	PRINT 'Create Campaign for HTM - 4. MediaMax'
	INSERT INTO Campaign(SiteID,[Name],Code,[Description],CreatedBy,DateCreated)
	VALUES(@SiteID,'MEDIAMAX','MEDIAMAXHTM','MediaMax HTM','McNiel Viray',@DateNow)

	SELECT @CampaignID = SCOPE_IDENTITY()
		INSERT INTO LoB(CampaignID,[Name],Code,[Description],CreatedBy,DateCreated)
		VALUES(@CampaignID,'MediaMax','MMHTM','MediaMax HTM','McNiel Viray',@DateNow)


PRINT 'Create Site for TaskHouse'

INSERT INTO [Site]([Name],Code,[Description],CreatedBy,DateCreated)
VALUES('TaskHouse','TH','Taskus Cavite','McNiel Viray', @DateNow)

SELECT @SiteID = SCOPE_IDENTITY()	

	PRINT 'Create Campaign for TH - 1. MediaMax'
	INSERT INTO Campaign(SiteID,[Name],Code,[Description],CreatedBy,DateCreated)
	VALUES(@SiteID,'MEDIAMAX','MEDIAMAXTH','MediaMax TH','McNiel Viray',@DateNow)

	SELECT @CampaignID = SCOPE_IDENTITY()
		INSERT INTO LoB(CampaignID,[Name],Code,[Description],CreatedBy,DateCreated)
		VALUES(@CampaignID,'MediaMax','MMTH','MediaMax TH','McNiel Viray',@DateNow)




	PRINT 'Create Campaign for TH - 2. Postmates'
	INSERT INTO Campaign(SiteID,[Name],Code,[Description],CreatedBy,DateCreated)
	VALUES(@SiteID,'POSTMATES','POSTMATESTH','Postmates TH','McNiel Viray',@DateNow)

	SELECT @CampaignID = SCOPE_IDENTITY()
		INSERT INTO LoB(CampaignID,[Name],Code,[Description],CreatedBy,DateCreated)
		VALUES(@CampaignID,'Full Time','PMFTTH',' TH','McNiel Viray',@DateNow)
		INSERT INTO LoB(CampaignID,[Name],Code,[Description],CreatedBy,DateCreated)
		VALUES(@CampaignID,'Part Time','PMPTTH',' TH','McNiel Viray',@DateNow)


	PRINT 'Create Campaign for TH - 3. MERCARI'
	INSERT INTO Campaign(SiteID,[Name],Code,[Description],CreatedBy,DateCreated)
	VALUES(@SiteID,'MERCARI','MERCARITH','MERCARI TH','McNiel Viray',@DateNow)

	SELECT @CampaignID = SCOPE_IDENTITY()
		INSERT INTO LoB(CampaignID,[Name],Code,[Description],CreatedBy,DateCreated)
		VALUES(@CampaignID,'Mercari CX','MERCCX','Mercar CX TH','McNiel Viray',@DateNow)
		INSERT INTO LoB(CampaignID,[Name],Code,[Description],CreatedBy,DateCreated)
		VALUES(@CampaignID,'Content Moderation','MERCCMTH','Mercari Content Moderation TH','McNiel Viray',@DateNow)



	PRINT 'Create Campaign for TH - 4. HUDL'
	INSERT INTO Campaign(SiteID,[Name],Code,[Description],CreatedBy,DateCreated)
	VALUES(@SiteID,'HUDL','HUDLTH','HUDL TH','McNiel Viray',@DateNow)

	SELECT @CampaignID = SCOPE_IDENTITY()
		INSERT INTO LoB(CampaignID,[Name],Code,[Description],CreatedBy,DateCreated)
		VALUES(@CampaignID,'Football - Full Time','FBFTTH','Football Full Time TH','McNiel Viray',@DateNow)
		INSERT INTO LoB(CampaignID,[Name],Code,[Description],CreatedBy,DateCreated)
		VALUES(@CampaignID,'Football - Part Time','FBPTTH','Football part time TH','McNiel Viray',@DateNow)
		INSERT INTO LoB(CampaignID,[Name],Code,[Description],CreatedBy,DateCreated)
		VALUES(@CampaignID,'Basketball - Full Time','BBFT','Basketball Full time TH','McNiel Viray',@DateNow)



PRINT 'Create Site for Lizzy''s Nook'

INSERT INTO [Site]([Name],Code,[Description],CreatedBy,DateCreated)
VALUES('Lizzy''s Nook','LN','Taskus Cavite-Lumina','McNiel Viray', @DateNow)

SELECT @SiteID = SCOPE_IDENTITY()

	PRINT 'Create Campaign for LN - 1. WISH'
	INSERT INTO Campaign(SiteID,[Name],Code,[Description],CreatedBy,DateCreated)
	VALUES(@SiteID,'WISH','WISHLN','WISH LN','McNiel Viray',@DateNow)

	SELECT @CampaignID = SCOPE_IDENTITY()	
		INSERT INTO LoB(CampaignID,[Name],Code,[Description],CreatedBy,DateCreated)
		VALUES(@CampaignID,'Email','EMAILLNWISH','Email WIh','McNiel Viray',@DateNow)
		INSERT INTO LoB(CampaignID,[Name],Code,[Description],CreatedBy,DateCreated)
		VALUES(@CampaignID,'Zendesk','ZDWISHLN','Zendesk','McNiel Viray',@DateNow)
		INSERT INTO LoB(CampaignID,[Name],Code,[Description],CreatedBy,DateCreated)
		VALUES(@CampaignID,'Content Moderation','CMWISHLN','Content moderation','McNiel Viray',@DateNow)
	
	
	
	PRINT 'Create Campaign for LN - 2. FREEDOMPOP'
	INSERT INTO Campaign(SiteID,[Name],Code,[Description],CreatedBy,DateCreated)
	VALUES(@SiteID,'FREEDOMPOP','FREEDOMPOLN','FREEDOMPOP LN','McNiel Viray',@DateNow)

	SELECT @CampaignID = SCOPE_IDENTITY()
		INSERT INTO LoB(CampaignID,[Name],Code,[Description],CreatedBy,DateCreated)
		VALUES(@CampaignID,'Service Agents','FPSALN','FPSALN','McNiel Viray',@DateNow)
		INSERT INTO LoB(CampaignID,[Name],Code,[Description],CreatedBy,DateCreated)
		VALUES(@CampaignID,'Sales Outbound','FPSOLN','FPSOLN','McNiel Viray',@DateNow)
		INSERT INTO LoB(CampaignID,[Name],Code,[Description],CreatedBy,DateCreated)
		VALUES(@CampaignID,'Online Services (email)','FPOSELN','FPOSELN','McNiel Viray',@DateNow)
		INSERT INTO LoB(CampaignID,[Name],Code,[Description],CreatedBy,DateCreated)
		VALUES(@CampaignID,'Sales Inbound','FPSILN','FPSILN','McNiel Viray',@DateNow)		




	PRINT 'Create Campaign for LN - 3. SPAREFOOT'
	INSERT INTO Campaign(SiteID,[Name],Code,[Description],CreatedBy,DateCreated)
	VALUES(@SiteID,'SPAREFOOT','SPAREFOOTLN','SPAREFOOT LN','McNiel Viray',@DateNow)

	SELECT @CampaignID = SCOPE_IDENTITY()	
		INSERT INTO LoB(CampaignID,[Name],Code,[Description],CreatedBy,DateCreated)
		VALUES(@CampaignID,'Sales','SFSALESLN','SFSALESLN','McNiel Viray',@DateNow)
		INSERT INTO LoB(CampaignID,[Name],Code,[Description],CreatedBy,DateCreated)
		VALUES(@CampaignID,'Support','SFSUPPORTLN','SFSUPPORTLN','McNiel Viray',@DateNow)



	PRINT 'Create Campaign for LN - 4. DELIVEROO'
	INSERT INTO Campaign(SiteID,[Name],Code,[Description],CreatedBy,DateCreated)
	VALUES(@SiteID,'DELIVEROO','DELIVEROOLN','DELIVEROO LN','McNiel Viray',@DateNow)

	SELECT @CampaignID = SCOPE_IDENTITY()	
		INSERT INTO LoB(CampaignID,[Name],Code,[Description],CreatedBy,DateCreated)
		VALUES(@CampaignID,'RS Outbound (SG/AU)','RSO','RS Outbound (SG/AU)','McNiel Viray',@DateNow)
		INSERT INTO LoB(CampaignID,[Name],Code,[Description],CreatedBy,DateCreated)
		VALUES(@CampaignID,'DS Inbound SG','DSISG','DS Inbound SG','McNiel Viray',@DateNow)
		INSERT INTO LoB(CampaignID,[Name],Code,[Description],CreatedBy,DateCreated)
		VALUES(@CampaignID,'DS Outbound AU','DSOAU','DS Outbound AU','McNiel Viray',@DateNow)
		INSERT INTO LoB(CampaignID,[Name],Code,[Description],CreatedBy,DateCreated)
		VALUES(@CampaignID,'Customer Calls AU','CCAU','Customer Calls AU','McNiel Viray',@DateNow)
		INSERT INTO LoB(CampaignID,[Name],Code,[Description],CreatedBy,DateCreated)
		VALUES(@CampaignID,'Restaurant Calls AU','RCAU','Restaurant Calls AU','McNiel Viray',@DateNow)
		INSERT INTO LoB(CampaignID,[Name],Code,[Description],CreatedBy,DateCreated)
		VALUES(@CampaignID,'Email SG','ESG','Email SG','McNiel Viray',@DateNow)
		INSERT INTO LoB(CampaignID,[Name],Code,[Description],CreatedBy,DateCreated)
		VALUES(@CampaignID,'Chat SG','CSG','Chat SG','McNiel Viray',@DateNow)
		INSERT INTO LoB(CampaignID,[Name],Code,[Description],CreatedBy,DateCreated)
		VALUES(@CampaignID,'Email AU','EAU','Email AU','McNiel Viray',@DateNow)
		INSERT INTO LoB(CampaignID,[Name],Code,[Description],CreatedBy,DateCreated)
		VALUES(@CampaignID,'Chat AU','CAU','Chat AU','McNiel Viray',@DateNow)
		INSERT INTO LoB(CampaignID,[Name],Code,[Description],CreatedBy,DateCreated)
		VALUES(@CampaignID,'Customer Calls SG','CCSG','Customer Calls SG','McNiel Viray',@DateNow)
		INSERT INTO LoB(CampaignID,[Name],Code,[Description],CreatedBy,DateCreated)
		VALUES(@CampaignID,'Restaurant Calls SG','RCSG','Restaurant Calls SG','McNiel Viray',@DateNow)
		INSERT INTO LoB(CampaignID,[Name],Code,[Description],CreatedBy,DateCreated)
		VALUES(@CampaignID,'UK Driver Support - Voice','UDSV','UK Driver Support - Voice','McNiel Viray',@DateNow)
		INSERT INTO LoB(CampaignID,[Name],Code,[Description],CreatedBy,DateCreated)
		VALUES(@CampaignID,'UK Restaurant Support','URS','UK Restaurant Support','McNiel Viray',@DateNow)
		INSERT INTO LoB(CampaignID,[Name],Code,[Description],CreatedBy,DateCreated)
		VALUES(@CampaignID,'UK Email','UKE','UK Email','McNiel Viray',@DateNow)
		INSERT INTO LoB(CampaignID,[Name],Code,[Description],CreatedBy,DateCreated)
		VALUES(@CampaignID,'UK Chat','UKC','UK Chat','McNiel Viray',@DateNow)
		INSERT INTO LoB(CampaignID,[Name],Code,[Description],CreatedBy,DateCreated)
		VALUES(@CampaignID,'UK Menu Transcription','UMT','UK Menu Transcription','McNiel Viray',@DateNow)
		INSERT INTO LoB(CampaignID,[Name],Code,[Description],CreatedBy,DateCreated)
		VALUES(@CampaignID,'UK Guru','UKG','UK Guru','McNiel Viray',@DateNow)
		INSERT INTO LoB(CampaignID,[Name],Code,[Description],CreatedBy,DateCreated)
		VALUES(@CampaignID,'UK Driver Support - Email','UDSE','UK Driver Support - Email','McNiel Viray',@DateNow)
		INSERT INTO LoB(CampaignID,[Name],Code,[Description],CreatedBy,DateCreated)
		VALUES(@CampaignID,'UK Restaurant Support - Email','UKRSE','UK Restaurant Support - Email','McNiel Viray',@DateNow)


PRINT 'Create Role'


INSERT INTO [Role]([Name],Code,[Description],CreatedBy,DateCreated)
VALUES('Administrator','ADMN','Administrator','McNiel Viray',@DateNow)
INSERT INTO [Role]([Name],Code,[Description],CreatedBy,DateCreated)
VALUES('Workforce','WFM','Workforce','McNiel Viray',@DateNow)
INSERT INTO [Role]([Name],Code,[Description],CreatedBy,DateCreated)
VALUES('Operations','OPS','Operations','McNiel Viray',@DateNow)
INSERT INTO [Role]([Name],Code,[Description],CreatedBy,DateCreated)
VALUES('Training','TRN','Training','McNiel Viray',@DateNow)
INSERT INTO [Role]([Name],Code,[Description],CreatedBy,DateCreated)
VALUES('Recruitment','RCT','Recruitment','McNiel Viray',@DateNow)
GO