//
//  NSObject+EPPZRepresentable.m
//  eppz!kit
//
//  Created by Borbás Geri on 8/22/13.
//  Copyright (c) 2013 eppz! development, LLC.
//
//  donate! by following http://www.twitter.com/_eppz
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
//  The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//

#import "NSObject+EPPZRepresentable.h"


//Temporary object pools Keyed by top-level objects representableId.
__strong static NSMutableDictionary *__objectPools;


static NSString *const EPPZRepresentableIDKey = @"__id";
static NSString *const EPPZRepresentableClassKey = @"__class";
static NSString *const EPPZRepresentableTypeKey = @"__type";
static NSString *const EPPZRepresentableInstanceType = @"instance";
static NSString *const EPPZRepresentableReferenceType = @"reference";


@interface NSObject (EPPZRepresentable_private)

@property (nonatomic, readonly) NSString *representableID;
-(NSString*)representedClassNameKey;

-(NSDictionary*)representedPropertyNamesForPropertyNames;
+(NSDictionary*)propertyNamesForRepresentedPropertyNames_; // Read once.

-(NSArray*)propertyNames;
+(NSArray*)propertyNamesOfObject:(NSObject*) object;
+(NSArray*)propertyNamesOfClass:(Class) class;
+(NSArray*)collectRepresentablePropertyNames;

+(NSMutableDictionary*)objectPools;
+(NSMutableDictionary*)objectPoolForRepresentable:(NSObject*) representable;
+(NSMutableDictionary*)addObjectPoolForRepresentable:(NSObject*) representable;
+(NSMutableDictionary*)addObjectPoolForRepresentableID:(NSString*) representableID;
+(void)removeObjectPoolForRepresentable:(NSObject*) representable;
+(void)removeObjectPoolForRepresentableID:(NSString*) representableID;
+(void)addRepresentable:(NSObject<EPPZRepresentable>*) representable toPool:(NSMutableDictionary*) objectPool;
+(BOOL)objectPool:(NSMutableDictionary*) objectPool hasRepresentable:(NSObject*) representable;
+(NSMutableDictionary*)objectPool:(NSMutableDictionary*) objectPool representationForRepresentable:(NSObject*) representable;

-(NSDictionary*)dictionaryRepresentationWithObjectPool:(NSMutableDictionary*) objectPool;
+(id)representableWithDictionaryRepresentation:(NSDictionary*) dictionaryRepresentation objectPool:(NSMutableDictionary*) objectPool;

@end


@implementation NSObject (EPPZRepresentable)


#pragma mark - Subclass templates

+(id)instance
{ return [self new]; }

+(NSArray*)representablePropertyNames
{ return nil; }

+(NSDictionary*)propertyNamesForRepresentedPropertyNames
{ return nil; }

+(Class)classForRepresentedClassName:(NSString*) representedClassName
{ return NSClassFromString(representedClassName); }

+(NSString*)representedClassNameForClass:(Class) class
{ return NSStringFromClass(class); }

-(void)willStore { }
-(void)didStore { }
-(void)willLoad { }
-(void)didLoad { }

-(void)willRepresented
{ [self willStore]; }

-(void)didRepresented
{ [self didStore]; }

-(void)willReconstructed
{ [self willLoad]; }

-(void)didReconstructed
{ [self didLoad]; }


+(NSString*)representedClassNameKey
{ return EPPZRepresentableClassKey; }

// Alias.
-(NSString*)representedClassNameKey
{ return [self.class representedClassNameKey]; }

+(BOOL)representID { return YES; }
+(BOOL)representClass { return YES; }
+(BOOL)representType { return YES; }
+(BOOL)representEmptyValues { return YES; }

+(BOOL)reconstructID { return YES; }
+(BOOL)reconstructClass { return YES; }
+(BOOL)reconstructType { return YES; }

+(id)representedValueForValue:(id) value
{ return nil; }

+(id)valueForRepresentedValue:(id) representedValue
{ return nil; }


#pragma mark - Feature management

+(BOOL)isRepresentableClass { return [self conformsToProtocol:@protocol(EPPZRepresentable)]; }
-(BOOL)isRepresentableObject { return [self.class conformsToProtocol:@protocol(EPPZRepresentable)]; }


#pragma mark - Object pools (track references)

-(NSString*)representableID
{ return @(self.hash).stringValue; }

+(NSMutableDictionary*)objectPools
{
    //Lazy.
    if (__objectPools == nil)
    { __objectPools = [NSMutableDictionary new]; }
    return __objectPools;
}

+(NSMutableDictionary*)objectPoolForRepresentable:(NSObject*) representable
{
    if ([[[self objectPools] allKeys] containsObject:representable.representableID])
    { return [[self objectPools] objectForKey:representable.representableID]; }
    return nil;
}

+(NSMutableDictionary*)addObjectPoolForRepresentable:(NSObject*) representable
{ return [self addObjectPoolForRepresentableID:representable.representableID]; }

+(NSMutableDictionary*)addObjectPoolForRepresentableID:(NSString*) representableID
{
    if ([[[self objectPools] allKeys] containsObject:representableID] == NO)
    {
        NSMutableDictionary *objectPool = [NSMutableDictionary new];
        [[self objectPools] setObject:objectPool forKey:representableID];
        return objectPool;
    }
    return nil;
}

+(void)removeObjectPoolForRepresentable:(NSObject*) representable
{ [self removeObjectPoolForRepresentableID:representable.representableID]; }

+(void)removeObjectPoolForRepresentableID:(NSString*) representableID
{
    if ([[[self objectPools] allKeys] containsObject:representableID])
    { [[self objectPools] removeObjectForKey:representableID]; }
}

+(void)addRepresentable:(NSObject<EPPZRepresentable>*) representable toPool:(NSMutableDictionary*) objectPool
{ [self addRepresentable:representable forID:representable.representableID toPool:objectPool]; }

+(void)addRepresentable:(NSObject<EPPZRepresentable>*) representable forID:(NSString*) representableID toPool:(NSMutableDictionary*) objectPool
{
    if ([[objectPool allKeys] containsObject:representableID] == NO)
        [objectPool setObject:representable forKey:representableID];
}

+(BOOL)objectPool:(NSMutableDictionary*) objectPool hasRepresentable:(NSObject<EPPZRepresentable>*) representable
{ return [self objectPool:objectPool hasRepresentableID:representable.representableID]; }

+(BOOL)objectPool:(NSMutableDictionary*) objectPool hasRepresentableID:(NSString*) representableID
{ return [[objectPool allKeys] containsObject:representableID]; }

+(NSMutableDictionary*)objectPool:(NSMutableDictionary*) objectPool representationForRepresentable:(NSObject*) representable
{
    if ([self objectPool:objectPool hasRepresentable:representable])
        return [objectPool objectForKey:representable.representableID];
    
    return nil;
}


#pragma mark - Property mapping

+(NSDictionary*)propertyNamesForRepresentedPropertyNames_
{
    static NSDictionary *_propertyNamesForRepresentedPropertyNames;
    if (_propertyNamesForRepresentedPropertyNames == nil)
    {
        // Read class template.
        _propertyNamesForRepresentedPropertyNames = [self propertyNamesForRepresentedPropertyNames];
    }
    return _propertyNamesForRepresentedPropertyNames;
}

+(NSDictionary*)representedPropertyNamesForPropertyNames
{
    static NSDictionary *_representedPropertyNamesForPropertyNames;
    if (_representedPropertyNamesForPropertyNames == nil)
    {
        NSMutableDictionary *swapped = [NSMutableDictionary new];
        [[self.class propertyNamesForRepresentedPropertyNames_] enumerateKeysAndObjectsUsingBlock:^(id key, id value, BOOL *stop)
        { [swapped setObject:key forKey:value]; }];
        _representedPropertyNamesForPropertyNames = swapped;
    }
    return _representedPropertyNamesForPropertyNames;
}

+(NSString*)propertyNameForRepresentedPropertyName:(NSString*) representedPropertyName
{
    NSString *propertyName = representedPropertyName;
    
    // Lookup for match.
    NSDictionary *map = [self propertyNamesForRepresentedPropertyNames_];
    if (map != nil)
        if ([[map allKeys] containsObject:representedPropertyName])
            propertyName = [map objectForKey:representedPropertyName];
    
    return propertyName;
}

// Read.
+(NSString*)representedPropertyNameForPropertyName:(NSString*) propertyName
{
    NSString *representedPropertyName = propertyName;
    
    // Lookup for match.
    NSDictionary *map = [self representedPropertyNamesForPropertyNames];
    if (map != nil)
        if ([[map allKeys] containsObject:propertyName])
            representedPropertyName = [map objectForKey:propertyName];
    
    return representedPropertyName;
}


#pragma mark - Objective-C introspection



#pragma mark - Represent

-(NSDictionary*)dictionaryRepresentation
{
    //Top-level dictionary.
    NSDictionary *dictionaryRepresentation = [self dictionaryRepresentationWithObjectPool:nil];
    
    //Release representations in pool after process.
    [NSObject removeObjectPoolForRepresentable:self];
    
    return dictionaryRepresentation;
}

-(NSDictionary*)dictionaryRepresentationWithObjectPool:(NSMutableDictionary*) objectPool
{
    ERLog(@"EPPZRepresentable dictionaryRepresentation '%@'", NSStringFromClass(self.class));
    
    // 1.
    
        // Default representation (class, id).
        NSMutableDictionary *dictionaryRepresentation = [self dictionaryWithIdentifiers];
    
        // Manage object pool instance.
        objectPool = [self createObjectPoolIfNeeded:objectPool];
    
    // 2.

        //Store only identifiers if already represented in this run.
        if ([NSObject objectPool:objectPool hasRepresentable:self])
        {
            // Return dictionary we have so far (without the values).
            return [NSDictionary dictionaryWithDictionary:dictionaryRepresentation];
        }
    
    // 3.

        // Mark __eppz.representable.type as instance (for easier reconstruction).
        if ([self.class representType])
        { [dictionaryRepresentation setObject:EPPZRepresentableInstanceType forKey:EPPZRepresentableTypeKey]; }
    
            // Track that this object is being represented already.
            [NSObject addRepresentable:(NSObject<EPPZRepresentable>*)self toPool:objectPool];
    
            // Collect property representations.
            [self collectPropertyValuesIntoDictionary:dictionaryRepresentation objectPool:objectPool];
    
    // 4.
    
        //Return immutable.
        return [NSDictionary dictionaryWithDictionary:dictionaryRepresentation];
}

-(NSMutableDictionary*)createObjectPoolIfNeeded:(NSMutableDictionary*) objectPool
{
    if (objectPool == nil)
    { return [NSObject addObjectPoolForRepresentable:self]; }
    
    return objectPool;
}

-(NSMutableDictionary*)dictionaryWithIdentifiers
{
    NSMutableDictionary *dictionaryRepresentation = [NSMutableDictionary new];
    
    //__eppz.representable.class.
    if ([self.class representClass])
    {
        [dictionaryRepresentation setObject:[self.class representedClassNameForClass:[self class]]
                                     forKey:[self representedClassNameKey]];
    }
    
    //__eppz.representable.id.
    if ([self.class representID])
    {
        [dictionaryRepresentation setObject:@(self.hash).stringValue
                                     forKey:EPPZRepresentableIDKey];
    }
    
    return dictionaryRepresentation;
}

-(void)collectPropertyValuesIntoDictionary:(NSMutableDictionary*) dictionaryRepresentation objectPool:(NSMutableDictionary*) objectPool
{
    // Subclass hook.
    [self willRepresented];
    
    for (NSString *eachPropertyName in [self propertyNames])
    {
        // Skip if no value.
        @try
        {
            // Property has no value.
            if ([self valueForKey:eachPropertyName] == nil) continue;
        }
        @catch (NSException *exception)
        {
            // Property is not key-value coding compilant.
            continue;
        }
        
        // Get represented value.
        id representedProperty = [self representationValueForPropertyName:eachPropertyName objectPool:objectPool];
        
        // Catch errors.
        if (representedProperty == nil &&
            [self.class representEmptyValues])
        { [EPPZRepresentableException object:self couldNotRepresentPropertyNamed:eachPropertyName]; }
        
        // Collect if any.
        if (representedProperty != nil)
        {
            NSString *key = [self.class representedPropertyNameForPropertyName:eachPropertyName];
            [dictionaryRepresentation setObject:representedProperty forKey:key];
        }
    }
    
    // Subclass hook.
    [self didRepresented];
}

-(id)representationValueForPropertyName:(NSString*) propertyName objectPool:(NSMutableDictionary*) objectPool
{
    // Get the actual (runtime) value for this key.
    
        id runtimeValue;
        @try { runtimeValue = [self valueForKeyPath:propertyName]; }
        @catch (NSException *exception)
        {
            [[EPPZRepresentableException object:self hasNoSuchPropertyNamed:propertyName] raise];
        }
    
        ERLog(@"EPPZRepresentable represent '%@.%@'...", NSStringFromClass(self.class), propertyName);
    
    // Try subclass representation value.
    
        id subclassRepresentationValue = [self.class representedValueForValue:runtimeValue];
    
    // EPPZRepresentable
    
        if ([runtimeValue conformsToProtocol:@protocol(EPPZRepresentable)])
        {
            NSObject <EPPZRepresentable> *runtimeRepresentable = (NSObject<EPPZRepresentable>*)runtimeValue;
            ERLog(@"...an EPPZRepresentable.");
            
            // Represent.
            NSDictionary *dictionaryRepresentation = [runtimeRepresentable dictionaryRepresentationWithObjectPool:objectPool];
            
            return dictionaryRepresentation;
        }
    
    // NSArray
    
        else if ([runtimeValue isKindOfClass:[NSArray class]])
        {
            NSArray *runtimeArray = (NSArray*)runtimeValue;
            ERLog(@"...an NSArray.");
            
            NSMutableArray *representationArray = [NSMutableArray new];
            
            // Check if empty.
            if (runtimeArray.count == 0 &&
                [self.class representEmptyValues] == NO)
                representationArray = nil;
            
            // Enumerate members.
            for (id eachRuntimeMember in runtimeArray)
            {
                // Represent each.
                id eachRepresentationMember = [eachRuntimeMember dictionaryRepresentationWithObjectPool:objectPool];
                [representationArray addObject:eachRepresentationMember];
            }
            
            return representationArray;
        }
    
    // NSSet (represent as array to stay JSON compilant)
    
        else if ([runtimeValue isKindOfClass:[NSSet class]])
        {
            NSSet *runtimeSet = (NSSet*)runtimeValue;
            ERLog(@"...an NSSet.");
            
            NSMutableArray *representationArray = [NSMutableArray new];
            
            // Check if empty.
            if (runtimeSet.count == 0 &&
                [self.class representEmptyValues] == NO)
                representationArray = nil;
            
            // Enumerate members.
            for (id eachRuntimeMember in runtimeSet)
            {
                // Represent each.
                id eachRepresentationMember = [eachRuntimeMember dictionaryRepresentationWithObjectPool:objectPool];
                [representationArray addObject:eachRepresentationMember];
            }
            
            return representationArray;
        }
    
    // NSDictionary
    
        else if ([runtimeValue isKindOfClass:[NSDictionary class]])
        {
            NSDictionary *runtimeDictionary = (NSDictionary*)runtimeValue;
            ERLog(@"...an NSDictionary.");
            
            NSMutableDictionary *representationDictionary = [NSMutableDictionary new];
            
            // Check if empty.
            if (runtimeDictionary.count == 0 &&
                [self.class representEmptyValues] == NO)
                representationDictionary = nil;
            
            // Enumerate members.
            [runtimeDictionary enumerateKeysAndObjectsUsingBlock:^(id eachKey, id eachRuntimeMember, BOOL *stop)
            {
                // Represent each.
                id eachRepresentationMember = [eachRuntimeMember dictionaryRepresentationWithObjectPool:objectPool];
                [representationDictionary setObject:eachRepresentationMember forKey:eachKey];
            }];
            
            return representationDictionary;
        }
    
    // NSNumber
    
        else if ([runtimeValue isKindOfClass:[NSNumber class]])
        {
            NSNumber *runtimeNumber = (NSNumber*)runtimeValue;
            ERLog(@"...an NSNumber.");
            
            NSNumber *representationNumber = runtimeNumber; // No conversion needed.
            
            // Check if empty.
            if (runtimeNumber.floatValue == 0.0 &&
                [self.class representEmptyValues] == NO)
                representationNumber = nil;
            
            return representationNumber; // No change.
        }
    
    // Subclass representation value
    
        else if (subclassRepresentationValue != nil)
        {
            return subclassRepresentationValue;
        }
    
    // The rest of the types goes trough representer.
    return [EPPZRepresenter representationValueFromRuntimeValue:runtimeValue];
}


#pragma mark - Reconstruction

+(id)representableWithDictionaryRepresentation:(NSDictionary*) dictionaryRepresentation
{
    // Checks.
    if (dictionaryRepresentation.count == 0) return nil;
    
    //Reconstruct.
    id representable = [self representableWithDictionaryRepresentation:dictionaryRepresentation objectPool:nil];

    // Look for ID, create if none.
    NSString *representableID = nil;
    if ([[dictionaryRepresentation allKeys] containsObject:EPPZRepresentableIDKey])
    { representableID = [dictionaryRepresentation objectForKey:EPPZRepresentableIDKey]; }
    else
    { representableID = @(dictionaryRepresentation.hash).stringValue; }
    
    //Flush temporary object pool.
    [NSObject removeObjectPoolForRepresentableID:representableID];
    
    return representable;
}

+(id)representableWithDictionaryRepresentation:(NSDictionary*) dictionaryRepresentation objectPool:(NSMutableDictionary*) objectPool
{
    //Get representable properties.
    
        //Determine class.
        NSString *className = [dictionaryRepresentation objectForKey:[self representedClassNameKey]];
        Class class = [self classForRepresentedClassName:className];
    
        //No such class.
        if (class == nil) return nil;
    
        // Look for ID, create if none.
        NSString *representableID = nil;
        if ([[dictionaryRepresentation allKeys] containsObject:EPPZRepresentableIDKey])
        { representableID = [dictionaryRepresentation objectForKey:EPPZRepresentableIDKey]; }
        else
        { representableID = @(dictionaryRepresentation.hash).stringValue; }
    
    //If reconstructed already, return object reference, else allocate a new.
    
        NSObject <EPPZRepresentable> *instance;
    
        BOOL isTopLevelObject = (objectPool == nil);
        if (isTopLevelObject)
        {
            //Create object pool (assuming this object is the top-level object).
            objectPool = [NSObject addObjectPoolForRepresentableID:representableID];
            
            //Create a new instance (for top-level object).
            if ([class respondsToSelector:@selector(instance)])
            { instance = [class instance]; }
            else
            { instance = [class new]; }
        }
        
        else
        {
            // Return allocated instance if already reconstructed.
            if ([NSObject objectPool:objectPool hasRepresentableID:representableID])
            {
                // Return the representable we have so far.
                instance = [objectPool objectForKey:representableID];
            }
            
            else
            {
                // Or go on with allocate a new instance.
                if ([class respondsToSelector:@selector(instance)])
                { instance = [class instance]; }
                else
                { instance = [class new]; }
            }
        }
    
    // Set values if this is the instance representatiton.
    BOOL isInstance = YES;
    
    // Look for reference type.
    if ([[dictionaryRepresentation allKeys] containsObject:EPPZRepresentableTypeKey])
    { isInstance = [[dictionaryRepresentation objectForKey:EPPZRepresentableTypeKey] isEqualToString:EPPZRepresentableInstanceType]; }
    
    if (isInstance)
    {
        // Subclass hook.
        [instance willReconstructed];
        
        // Set values.
        for (NSString *eachRepresentedPropertyName in dictionaryRepresentation.allKeys)
        {
            // Exclude class name, id.
            if ([eachRepresentedPropertyName isEqualToString:EPPZRepresentableIDKey] && [self reconstructID] == NO) continue;
            if ([eachRepresentedPropertyName isEqualToString:[self representedClassNameKey]] && [self reconstructClass] == NO) continue;
            
            // Get value.
            id eachRepresentationValue = [dictionaryRepresentation valueForKey:eachRepresentedPropertyName];
            
            // Create runtime value.
            id runtimeValue = [self runtimeValueFromRepresentationValue:eachRepresentationValue objectPool:objectPool];
            
            // Get property name.
            NSString *runtimeKey = [self propertyNameForRepresentedPropertyName:eachRepresentedPropertyName];
            
                // Setting NSSet from NSArray (CoreData relationship setting workaround).
                if ([runtimeValue isKindOfClass:[NSArray class]])
                {
                    // Look if the property is an NSSet.
                    Class propertyClass = [instance classOfPropertyNamed:runtimeKey];
                    if ([propertyClass isSubclassOfClass:[NSSet class]])
                    {
                        NSSet *runtimeSet = [NSSet setWithArray:runtimeValue];
                        runtimeValue = runtimeSet;
                    }
                }

            // Try to set.
            @try { [instance setValue:runtimeValue forKeyPath:runtimeKey]; }
            @catch (NSException *exception) { }
            @finally { }
        }
        
        // Subclass hook.
        [instance didReconstructed];
    }
    
    return instance;
}

-(id)runtimeValueFromRepresentationValue:(id) representationValue objectPool:(NSMutableDictionary*) objectPool
{
    id runtimeValue;
    
    // Check subclass implementation.
    id subclassRuntimeValue = [self.class valueForRepresentedValue:representationValue];
    
    // Look for <EPPZRepresentable> or NSDictionary
    if ([representationValue isKindOfClass:[NSDictionary class]])
    {
        NSDictionary *representationValueDictionary = (NSDictionary*)representationValue;
        Class class = class = [NSDictionary class];
        
        // Create custom class if present.
        if ([[representationValueDictionary allKeys] containsObject:[self representedClassNameKey]])
        {
            NSString *className = [representationValueDictionary objectForKey:[self representedClassNameKey]];
            class = [self.class classForRepresentedClassName:className];
        }
        
        // Create representable.
        runtimeValue = [class representableWithDictionaryRepresentation:representationValueDictionary objectPool:objectPool];
        
        // Look for ID, create if none.
        NSString *representableID = nil;
        if ([[representationValueDictionary allKeys] containsObject:EPPZRepresentableIDKey])
        { representableID = [representationValueDictionary objectForKey:EPPZRepresentableIDKey]; }
        else
        { representableID = @(representationValueDictionary.hash).stringValue; }
        
        // Track that this object have reconstructed already (with the stored ID).
        [NSObject addRepresentable:runtimeValue
                             forID:representableID
                            toPool:objectPool];
    }
    
    // Look into NSArray for any representable.
    else if ([representationValue isKindOfClass:[NSArray class]])
    {
        NSArray *representationValueArray = (NSArray*)representationValue;
        NSMutableArray *runtimeArray = [NSMutableArray new];
        
        [representationValueArray enumerateObjectsUsingBlock:^(id eachRepresentationValue, NSUInteger index, BOOL *stop)
        {
            // Reconstruct each.
            id eachRuntimeValue = [self runtimeValueFromRepresentationValue:eachRepresentationValue objectPool:objectPool];

            // Collect.
            [runtimeArray addObject:eachRuntimeValue];
        }];
        
        // Whoa, remains a mutable array.
        runtimeValue = runtimeArray;
    }
    
    // Subclass implementation.
    else if (subclassRuntimeValue != nil)
    {
        runtimeValue = subclassRuntimeValue;
    }
    
    // Simply return arbitrary value.
    else
    {
        runtimeValue = [EPPZRepresenter runtimeValueFromRepresentationValue:representationValue];
    }
    
    return runtimeValue;
    
}


#pragma mark - Property names

-(NSArray*)representedPropertyNames
{ return self.propertyNames; }

-(NSArray*)propertyNames
{ return [self.class propertyNamesOfObject:self]; }

+(NSArray*)propertyNamesOfObject:(NSObject*) object
{ return [self propertyNamesOfClass:object.class]; }

+(NSArray*)propertyNamesOfClass:(Class) class
{
    // Collection.
    NSMutableArray *collectedPropertyNames = [NSMutableArray new];
    
    // Collect properties from superclass (up till EPPZRepresentable).
    Class superclass = [self superclass];
    BOOL superclassPropertiesShouldCollected = [superclass conformsToProtocol:@protocol(EPPZRepresentable)]; // [superclass isSubclassOfClass:[EPPZRepresentable class]] && ([NSStringFromClass(superclass) isEqualToString:@"EPPZRepresentable"] == NO);
    if (superclassPropertiesShouldCollected)
    {
        // Only properties that have not collected so far.
        NSArray *superClassPropertyNames = [superclass propertyNamesOfClass:[self superclass]];
        [superClassPropertyNames enumerateObjectsUsingBlock:^(id object, NSUInteger index, BOOL *stop)
        {
            NSString *eachPropertyName = (NSString*)object;
            if ([collectedPropertyNames containsObject:eachPropertyName] == NO)
                [collectedPropertyNames addObject:eachPropertyName];
        }];
    }
    
    // Collect properties from this class.
    [collectedPropertyNames addObjectsFromArray:[self collectRepresentablePropertyNames]];
    
    // Return immutable copy.
    return [NSArray arrayWithArray:collectedPropertyNames];
}

+(NSArray*)collectRepresentablePropertyNames
{
    // User-defined property names if any.
    if ([self respondsToSelector:@selector(representablePropertyNames)])
        if ([self representablePropertyNames] != nil)
            return [self representablePropertyNames];
    
    // Collection.
    NSMutableArray *propertyNames = [NSMutableArray new];
    
    // Collect for this class.
    unsigned int propertyCount;
    objc_property_t *properties = class_copyPropertyList(self, &propertyCount);
    
    for (int index = 0; index < propertyCount; index++)
    {
        NSString *key = [NSString stringWithUTF8String:property_getName(properties[index])];
        [propertyNames addObject:key];
    }
    
    free(properties);
    
    // Return immutable copy.
    return [NSArray arrayWithArray:propertyNames];
}


#pragma mark - Objective-C introspection

-(NSString*)typeOfPropertyNamed:(NSString*) propertyName
{
    // Get Class of property to be populated.
    NSString *propertyType = nil;
    
    objc_property_t property = class_getProperty([self class], [propertyName UTF8String]);
    if (property == NULL) return nil;
    
    const char *propertyAttributesCString = property_getAttributes(property);
    if (propertyAttributesCString == NULL) return nil;
    
    NSString *propertyAttributes = [NSString stringWithCString:propertyAttributesCString encoding:NSUTF8StringEncoding];
    NSArray *splitPropertyAttributes = [propertyAttributes componentsSeparatedByString:@","];
    if (splitPropertyAttributes.count > 0)
    {
        // Objective-C Runtime Programming Guide
        // xcdoc://ios//library/prerelease/ios/documentation/Cocoa/Conceptual/ObjCRuntimeGuide/Articles/ocrtPropertyIntrospection.html
        NSString *encodeType = splitPropertyAttributes[0];
        NSArray *splitEncodeType = [encodeType componentsSeparatedByString:@"\""];
        propertyType = (splitEncodeType.count > 1) ? splitEncodeType[1] : [self typeNameForTypeEncoding:encodeType];
    }
    return propertyType;
    
}

-(NSString*)typeNameForTypeEncoding:(NSString*) typeEncoding
{
    // Type Encodings
    // xcdoc://ios//library/prerelease/ios/documentation/Cocoa/Conceptual/ObjCRuntimeGuide/Articles/ocrtTypeEncodings.html
    NSDictionary *typeNamesForTypeEncodings = @{
                                                @"Tc" : @"char",
                                                @"Ti" : @"int",
                                                @"Ts" : @"short",
                                                @"Tl" : @"long",
                                                @"Tq" : @"long long",
                                                @"TC" : @"unsigned char",
                                                @"TI" : @"unsigned int",
                                                @"TS" : @"unsigned short",
                                                @"TL" : @"unsigned long",
                                                @"TQ" : @"unsigned long long",
                                                @"Tf" : @"float",
                                                @"Td" : @"double",
                                                @"Tv" : @"void",
                                                @"T*" : @"character string",
                                                @"T@" : @"id",
                                                @"T#" : @"Class",
                                                @"T:" : @"SEL",
                                                };
    
    if ([[typeNamesForTypeEncodings allKeys] containsObject:typeEncoding])
    { return [typeNamesForTypeEncodings objectForKey:typeEncoding]; }
    return @"unknown";
}

-(Class)classOfPropertyNamed:(NSString*) propertyName
{ return NSClassFromString([self typeOfPropertyNamed:propertyName]); }



@end
