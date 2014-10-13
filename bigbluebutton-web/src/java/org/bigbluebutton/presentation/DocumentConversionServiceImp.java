/**
* BigBlueButton open source conferencing system - http://www.bigbluebutton.org/
* 
* Copyright (c) 2012 BigBlueButton Inc. and by respective authors (see below).
*
* This program is free software; you can redistribute it and/or modify it under the
* terms of the GNU Lesser General Public License as published by the Free Software
* Foundation; either version 3.0 of the License, or (at your option) any later
* version.
* 
* BigBlueButton is distributed in the hope that it will be useful, but WITHOUT ANY
* WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A
* PARTICULAR PURPOSE. See the GNU Lesser General Public License for more details.
*
* You should have received a copy of the GNU Lesser General Public License along
* with BigBlueButton; if not, see <http://www.gnu.org/licenses/>.
*
*/

package org.bigbluebutton.presentation;

import org.bigbluebutton.api.messaging.MessagingService;
import org.bigbluebutton.presentation.imp.ImageToSwfSlidesGenerationService;
import org.bigbluebutton.presentation.imp.OfficeToPdfConversionService;
import org.bigbluebutton.presentation.imp.PdfToSwfSlidesGenerationService;

// import java.io.BufferedReader;
// import java.io.BufferedWriter;
// import java.io.FileReader;
// import java.io.FileWriter;
import java.io.*;

public class DocumentConversionServiceImp implements DocumentConversionService {
	private MessagingService messagingService;
	private OfficeToPdfConversionService officeToPdfConversionService;
	private PdfToSwfSlidesGenerationService pdfToSwfSlidesGenerationService;
	private ImageToSwfSlidesGenerationService imageToSwfSlidesGenerationService;
	
	public void processDocument(UploadedPresentation pres) {
		SupportedDocumentFilter sdf = new SupportedDocumentFilter(messagingService);
		if (sdf.isSupported(pres)) {
			String fileType = pres.getFileType();
			
			if (SupportedFileTypes.isOfficeFile(fileType)) {
				officeToPdfConversionService.convertOfficeToPdf(pres);
				OfficeToPdfConversionSuccessFilter ocsf = new OfficeToPdfConversionSuccessFilter(messagingService);
				if (ocsf.didConversionSucceed(pres)) {
					// Successfully converted to pdf. Call the process again, this time it should be handled by 
					// the PDF conversion service.
					processDocument(pres);
				}
			} else if (SupportedFileTypes.isPdfFile(fileType)) {
				pdfToSwfSlidesGenerationService.generateSlides(pres);
			} else if (SupportedFileTypes.isImageFile(fileType)) {
				imageToSwfSlidesGenerationService.generateSlides(pres);
			} else {
				
			}
						
		} else {
			// TODO: error log
		}
	}

	public void copyFileForDownload (UploadedPresentation pres) throws IOException {
		InputStream is = null;
    	OutputStream os = null;
    	File source = pres.getUploadedFile();
    	File dir = new File ("/var/www/bigbluebutton/bbb-files/" + pres.getConference() + "/" + pres.getRoom());

		if (dir.exists() == false) {
			dir.mkdirs();
		}
		File dest = new File (dir, source.getName());

	    try {
	        is = new FileInputStream(source);
	        os = new FileOutputStream(dest);
	        byte[] buffer = new byte[1024];
	        int length;
	        while ((length = is.read(buffer)) > 0) {
	            os.write(buffer, 0, length);
	        }
		} finally {
	        is.close();
	        os.close();
	    }

		// try {
		// 	File fl = pres.getUploadedFile();
		// 	File dir = new File ("/var/www/bigbluebutton/bbb-files/" + pres.getConference() + "/" + pres.getRoom());

		// 	if (dir.exists() == false) {
		// 		dir.mkdirs();
		// 	}
		// 	File outputFile = new File (dir, fl.getName());
		// 	FileReader input = new FileReader (fl);

		// 	char buf[] = new char[512];
		// 	BufferedWriter bw = new BufferedWriter(new FileWriter(outputFile));
		// 	BufferedReader br = new BufferedReader (input);

		// 	int count = br.read (buf, 0, 512);
		// 	int total = count;

		// 	while (count > 0) {
		// 		bw.write (buf, 0, count);
		// 		count = br.read (buf, 0, 512);
		// 		total += count;
		// 	}

		// 	bw.close();
		// 	br.close();

		// 	System.out.println ("##################### TOTAL CHARS RW: " + total);

		// } catch (IOException e) {
		// 	e.printStackTrace();
		// }
	}
	
	public void setMessagingService(MessagingService m) {
		messagingService = m;
	}
	
	public void setOfficeToPdfConversionService(OfficeToPdfConversionService s) {
		officeToPdfConversionService = s;
	}
	
	public void setPdfToSwfSlidesGenerationService(PdfToSwfSlidesGenerationService s) {
		pdfToSwfSlidesGenerationService = s; 
	}
	
	public void setImageToSwfSlidesGenerationService(ImageToSwfSlidesGenerationService s) {
		imageToSwfSlidesGenerationService = s;
	}
}
