//-------------------------------------------------------------------------------
// Copyright 2014 IBM Corp. All Rights Reserved
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//-------------------------------------------------------------------------------

#import <Foundation/Foundation.h>
#import <IBMData/IBMData.h>

@interface RobotRemote : IBMDataObject <IBMDataObjectSpecialization>

@property(nonatomic, copy) NSMutableDictionary *robot;

@property(nonatomic, copy) NSString *name;
@property(nonatomic, copy) NSString *clue;
@property(nonatomic, copy) NSString *disruption;
@property(nonatomic, copy) NSString *zone;
@property(nonatomic, copy) NSString *mugshotBase64;
@property(nonatomic, copy) NSString *mugshot;
@property(nonatomic, copy) NSString *fullbody;
@property(nonatomic, copy) NSString *fullBase64;
@property(nonatomic, copy) NSString *beacon;
@property(nonatomic, copy) NSString *primaryColor;
@property(nonatomic, copy) NSString *secondaryColor;
@property(nonatomic, copy) NSNumber *steps;

@end
