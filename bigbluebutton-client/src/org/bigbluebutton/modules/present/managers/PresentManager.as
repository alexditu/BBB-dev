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
package org.bigbluebutton.modules.present.managers
{
	import com.asfusion.mate.events.Dispatcher;
	
	import mx.collections.ArrayCollection;
	import mx.managers.PopUpManager;
	
	import org.bigbluebutton.common.IBbbModuleWindow;
	import org.bigbluebutton.common.LogUtil;
	import org.bigbluebutton.common.events.OpenWindowEvent;
	import org.bigbluebutton.core.managers.UserManager;
	import org.bigbluebutton.main.model.users.BBBUser;
	import org.bigbluebutton.main.model.users.Conference;
	import org.bigbluebutton.main.model.users.events.RoleChangeEvent;
	import org.bigbluebutton.modules.present.events.PresentModuleEvent;
	import org.bigbluebutton.modules.present.events.QueryListOfPresentationsReplyEvent;
	import org.bigbluebutton.modules.present.events.RemovePresentationEvent;
	import org.bigbluebutton.modules.present.events.UploadEvent;
	import org.bigbluebutton.modules.present.ui.views.FileUploadWindow;
	import org.bigbluebutton.modules.present.ui.views.PresentationWindow;

	import org.bigbluebutton.modules.present.ui.views.FileDownloadWindow;
	
	public class PresentManager
	{
		private var globalDispatcher:Dispatcher;
		private var uploadWindow:FileUploadWindow;
		private var presentWindow:PresentationWindow;
		private var downloadWindow:FileDownloadWindow;
		
		//format: presentationNames = [{label:"00"}, {label:"11"}, {label:"22"} ];
		[Bindable] public var presentationNames:ArrayCollection = new ArrayCollection();
		
		public function PresentManager() {
			globalDispatcher = new Dispatcher();
		}
		
		public function handleStartModuleEvent(e:PresentModuleEvent):void{
			if (presentWindow != null){ 
				return;
			}
			presentWindow = new PresentationWindow();
			presentWindow.visible = (e.data.showPresentWindow == "true");
			presentWindow.showControls = (e.data.showWindowControls == "true");
			openWindow(presentWindow);
		}
		
		public function handleStopModuleEvent():void{
			presentWindow.close();
		}
		
		private function openWindow(window:IBbbModuleWindow):void{
			var event:OpenWindowEvent = new OpenWindowEvent(OpenWindowEvent.OPEN_WINDOW_EVENT);
			event.window = window;
			globalDispatcher.dispatchEvent(event);
		}
	
		public function handleOpenUploadWindow(e:UploadEvent):void{
			if (uploadWindow != null) return;
			
			uploadWindow = new FileUploadWindow();
			uploadWindow.presentationNamesAC = presentationNames;
			uploadWindow.maxFileSize = e.maxFileSize;
			mx.managers.PopUpManager.addPopUp(uploadWindow, presentWindow, true);
		}

		public function handleOpenDownloadWindow (e:UploadEvent):void {
			trace ("In handleOpenDownloadWindow1");
			downloadWindow = new FileDownloadWindow();
			downloadWindow.filesToDownload = e.filesToDownload;
			trace ("In handleOpenDownloadWindow2");
			mx.managers.PopUpManager.addPopUp(downloadWindow, presentWindow, true);
			trace ("In handleOpenDownloadWindow3");
		}

		public function handleCloseDownloadWindow(e:UploadEvent):void {
			trace ("In handleCloseDownloadWindow");
			PopUpManager.removePopUp(downloadWindow);
			downloadWindow = null;
		}
		
		public function handleCloseUploadWindow(e:UploadEvent):void{
			PopUpManager.removePopUp(uploadWindow);

			if ((presentWindow != null) && (uploadWindow != null)) {
				if (e.enableSave != null) {
					presentWindow.setSaveBtnStatus(e.enableSave);
				}
				presentWindow.fileToSave = uploadWindow.fileToSaveName;
				trace ("presentWindow.fileToSave = " + presentWindow.fileToSave);
				trace ("uploadWindow.fileToSaveName = " + uploadWindow.fileToSaveName);
			} else {
				trace ("presentWindow or uploadWindow is null");
			}
			uploadWindow = null;
		}
		
		public function updatePresentationNames(e:UploadEvent):void{
			LogUtil.debug("Adding presentation " + e.presentationName);
			for (var i:int = 0; i < presentationNames.length; i++) {
				if (presentationNames[i] == e.presentationName) return;
			}
			presentationNames.addItem(e.presentationName);
		}

		public function removePresentation(e:RemovePresentationEvent):void {
			LogUtil.debug("Removing presentation " + e.presentationName);
      var p:String;
      
      for (var i:int = 0; i < presentationNames.length; i++) {
        p = presentationNames.getItemAt(i) as String;
        if (p == e.presentationName) {
          presentationNames.removeItemAt(i);
        }
      }
		}
    
    public function queryPresentations():void {
      var pArray:Array = new Array();
      pArray = presentationNames.toArray();
      
      var qEvent:QueryListOfPresentationsReplyEvent = new QueryListOfPresentationsReplyEvent();
      qEvent.presentations = pArray;
      globalDispatcher.dispatchEvent(qEvent);
    }
	}
}