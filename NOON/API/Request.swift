//  Created by Amin on 2/22/19.
//  Copyright © 2019 Amin. All rights reserved.

import Foundation
import Alamofire
import ObjectMapper
import ProgressHUD
import SwiftyJSON

class Request {
    
    var callerVC:UIViewController?
    
    init() {
    }
    
    init(callerVC:UIViewController) {
        self.callerVC = callerVC
    }
    
    private func send(url:String,
                      method:HTTPMethod,
                      parameters:Parameters? = nil,
                      encoding:JSONEncoding = JSONEncoding.default,
                      onResponse:@escaping ((_ response:DataResponse<Data>)->()),
                      onFailure:((_ error:Error,_ response:DataResponse<Data> )->())?) {
        
        if (!Util().isConnectedToInternet) {
            if let vc = callerVC{
                Util.alert(
                    title: ":خطا",
                    message: "دسترسی به اینترنت امکان پذیر نمیباشد",
                    buttonTitle: "متوجه شدم",
                    vc: vc)
            }
        } else {
            Alamofire.request(
                url,
                method: method,
                parameters: parameters,
                encoding: encoding,
                headers: Routes().getHeaders())/*.validate(statusCode: 200..<300)*/.responseData{ response in
                    switch response.result {
                    case .success:
                        do {
                            print("CLIENT -> routes: \(url)")
                            print("CLIENT -> params: \(parameters?.description ?? "PARAMS")")
                            print("SERVER -> status code : \(response.response?.statusCode ?? 999)")
                            onResponse(response)
                        }
                    case .failure(let error):
                        do {
                            var errorMessage:String = String(data: (response.data)!, encoding: .utf8)!
                            if parameters != nil {
                                errorMessage += "\n *** PARAMETERS ***\n" + JSON(parameters!).rawString()!
                            }
                            print("CLIENT -> routes: \(url)")
                            print("CLIENT -> params: \(String(describing: parameters))")
                            print("SERVER -> status code : \(String(describing: response.response?.statusCode))")
                            print("CLIENT -> error message: \(errorMessage)")
                            if onFailure != nil {
                                onFailure!(error,response)
                            }
                            #if DEBUG
                            #else
                            #endif
                        }
                    }
            }
        }
    }
    
    private func uploadImages(url:String,
                              method:HTTPMethod,
                              imagesDictionary:[String:UIImage],
                              comperessionPercentage:CGFloat = 0.5,
                              headers:HTTPHeaders = Routes().getHeaders(),
                              onProgress:((_ progress:Progress)->())?,
                              onResponse:@escaping ((_ response:DataResponse<Any>)->()),
                              onFailure:((_ error:Error )->())?,
                              type:String = "image/jpeg"){
        var url = try! URLRequest(url: url, method: method, headers: headers)
        url.timeoutInterval = 119
        ProgressHUD.show().self
        
        Alamofire.upload(multipartFormData: { multipartFormData in
            for i in imagesDictionary {
                let imageData = i.value.jpegData(compressionQuality: comperessionPercentage)
                multipartFormData.append(imageData!, withName: i.key, fileName: i.key, mimeType: type)
            }
        },with: url, encodingCompletion: { result in
            switch result {
            case .success(let upload, _, _):
                do{
                    ProgressHUD.showSuccess()
                    upload.responseJSON { response in
                        onResponse(response)
                        }.uploadProgress { progress in
                            if onProgress != nil {onProgress!(progress)}
                    }
                }
            case .failure(let error):
                do {
                    ProgressHUD.showError()
                    print("Request -> send function error code : \(error._code)")
                    if onFailure != nil {
                        onFailure!(error)
                    }
                }
            }
        })
    }
    
    func uploadPhoto(imagesDictionary: [String:UIImage],
                     onProgress:((_ progress:Progress)->())?,
                     onSuccess:(()->())?,
                     onFailure:((_ error:Error)->())?){
        uploadImages(url: Routes.User.UPLOAD,
                     method: .post,
                     imagesDictionary: imagesDictionary,
                     onProgress: onProgress,
                     onResponse: {response in onSuccess?()
        },onFailure: onFailure)
    }
    
    func uploadVideo(imagesDictionary: [String:UIImage],
                     onProgress:((_ progress:Progress)->())?,
                     onSuccess:(()->())?,
                     onFailure:((_ error:Error)->())?){
        uploadImages(url: Routes.User.UPLOAD,
                     method: .post,
                     imagesDictionary: imagesDictionary,
                     onProgress: onProgress,
                     onResponse: {response in onSuccess?()
        },onFailure: onFailure, type: "video/mp4")
    }
    
    func signIn(params: Parameters, onSuccess:(()->())?, onFailure:((_ error:Error,_ response:DataResponse<Data> )->())?) {
        send(url: Routes.User.LOGIN, method: .post, parameters: params, onResponse: { response in
            print(try! JSON(data: response.data!)["VerificationCode"])
            onSuccess!()
        }, onFailure: onFailure)
    }
    
    func mobileVerification(params: Parameters, onSuccess:(()->())?, onFailure:((_ error:Error,_ response:DataResponse<Data> )->())?) {
        send(url: Routes.User.VERIFY, method: .post, parameters: params, onResponse: { response in
            Util.putString(key: Constant.TOKEN, string: try! JSON(data: response.data!)["Token"].description)
            //            UserDefaults.standard.set(try! JSON(data: response.data!)["Token"].description,
            //                                      forKey: Constant.TOKEN)
            
            Util.putString(key: Constant.User.ID, string: try! JSON(data: response.data!)["UserId"].description)
            //            UserDefaults.standard.set(try! JSON(data: response.data!)["UserId"].description,
            //                                      forKey: Constant.User.ID)
            
            onSuccess!()
        }, onFailure: onFailure)
    }
    
    func editProfile(params: Parameters,onSuccess:(()->())?,onFailure:((_ error:Error,_ response:DataResponse<Data> )->())?) {
        send(url: Routes.User.UPDATE, method: .post, parameters: params, onResponse: { response in onSuccess!()}, onFailure: onFailure)
    }
    
    func getEvents(page: Int, params: Parameters, onSuccess:((_ event:[Event],_ nextPage:Int,_ lastPage:Int)->())?,
                   onFailure:((_ error:Error,_ response:DataResponse<Data> )->())?) {
        send(url: Routes.Events.List (page: page), method: .post, parameters: params, onResponse: {response in
            
            var events = [Event]()
            if String(data: (response.data)!, encoding: .utf8)! != "" {
                let json = try! JSON(data:response.data!)
                let event = json["Docs"]
                let currentPage = json["CurrentPage"].intValue
                let pageCount = json["Pages"].intValue
                
                if Mapper<Event>().mapArray(JSONString: event.rawString()!) != nil {
                    events = Mapper<Event>().mapArray(JSONString: event.rawString()!)!
                }
                print(events.count)
                onSuccess!(events, currentPage, pageCount)
            }
        }, onFailure: onFailure)
    }
    
    func setReady(params: Parameters, onSuccess:(() -> ())?, onFailure:((_ error:Error,_ response:DataResponse<Data> )->())?) {
        send(url: Routes.Events.SET_READY, method: .post, parameters: params, onResponse: {response in onSuccess!()}, onFailure: onFailure)
    }
    
    func getTutorials(page: Int, onSuccess:((_ tutorial:[Tutorial],_ nextPage:Int,_ lastPage:Int)->())?,
                      onFailure:((_ error:Error,_ response:DataResponse<Data> )->())?) {
        send(url: Routes.Tutorial.List(page: page), method: .get, onResponse: {response in
            var tutorials = [Tutorial]()
            let json = try! JSON(data:response.data!)
            let tutorial = json["Docs"]
            let currentPage = json["CurrentPage"].intValue
            let pageCount = json["PageCount"].intValue
            
            if Mapper<Tutorial>().mapArray(JSONString: tutorial.rawString()!) != nil {
                tutorials = Mapper<Tutorial>().mapArray(JSONString: tutorial.rawString()!)!
                onSuccess!(tutorials,currentPage + 1,pageCount)
            }
        }, onFailure: onFailure)
    }
    
    func getCourses(tutorialId: Int, onSuccess:((_ course:[Course],_ nextPage:Int,_ lastPage:Int)->())?,
                    onFailure:((_ error:Error,_ response:DataResponse<Data> )->())?) {
        send(url: Routes.Course().Courses(tutorialId: tutorialId) , method: .get, onResponse: {response in
            var courses = [Course]()
            let json = try! JSON(data:response.data!)
            let course = json["Docs"]
            let currentPage = json["CurrentPage"].intValue
            let pageCount = json["PageCount"].intValue
            
            if Mapper<Course>().mapArray(JSONString: course.rawString()!) != nil {
                courses = Mapper<Course>().mapArray(JSONString: course.rawString()!)!
                onSuccess!(courses,currentPage + 1, pageCount)
            }
        }, onFailure: onFailure)
    }
    
    func getNews(page: Int, onSuccess:((_ news:[News],_ nextPage:Int,_ lastPage:Int)->())?, onFailure:((_ error:Error,_ response:DataResponse<Data> )->())?) {
        send(url: Routes.News.List(page: page), method: .get, onResponse: {response in
            var news = [News]()
            let json = try! JSON(data:response.data!)
            let new = json["Docs"]
            let currentPage = json["CurrentPage"].intValue
            let pageCount = json["PageCount"].intValue
            
            if Mapper<News>().mapArray(JSONString: new.rawString()!) != nil {
                news = Mapper<News>().mapArray(JSONString: new.rawString()!)!
            }
            onSuccess!(news, currentPage, pageCount)
        }, onFailure: onFailure)
    }
    
    func getProfile(onSuccess:((_ user:User)->())?, onFailure:((_ error:Error,_ response:DataResponse<Data> )->())?) {
        send(url: Routes.User.PROFILE, method: .get, onResponse: {response in
            var user = User()
            let json = try! JSON(data:response.data!)
            if Mapper<User>().map(JSONString: json.rawString()!) != nil {
                user = Mapper<User>().map(JSONString: json.rawString()!)!
            }
            onSuccess!(user)
        }, onFailure: onFailure)
    }
}
