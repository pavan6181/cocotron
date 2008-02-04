/* Copyright (c) 2006-2007 Christopher J. W. Lloyd

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

// Original - Christopher Lloyd <cjwl@objc.net>
#import <Foundation/NSDictionary.h>
#import <Foundation/NSArray.h>
#import <Foundation/NSData.h>
#import <Foundation/NSDictionary_mapTable.h>
#import <Foundation/NSEnumerator_dictionaryObjects.h>
#import <Foundation/NSPropertyListReader.h>
#import <Foundation/NSPropertyListWriter_vintage.h>
#import <Foundation/NSRaise.h>
#import <Foundation/NSCoder.h>
#import <Foundation/NSKeyedUnarchiver.h>
#import <Foundation/NSURL.h>
#import <Foundation/NSAutoreleasePool.h>

@implementation NSDictionary

+allocWithZone:(NSZone *)zone {
   if(self==OBJCClassFromString("NSDictionary"))
    return NSAllocateObject([NSDictionary_mapTable class],0,zone);

   return NSAllocateObject(self,0,zone);
}


-init {
   return [self initWithObjects:NULL forKeys:NULL count:0];
}

-initWithObjects:(id *)objects forKeys:(id *)keys count:(unsigned)count {
   NSInvalidAbstractInvocation();
   return nil;
}

-initWithObjects:(NSArray *)objectArray forKeys:(NSArray *)keyArray {
   unsigned count=[objectArray count];
   id       objects[count],keys[count];

   [objectArray getObjects:objects];
   [keyArray getObjects:keys];

   return [self initWithObjects:objects forKeys:keys count:count];
}

-initWithDictionary:(NSDictionary *)dictionary {
   unsigned      i,count=[dictionary count];
   NSEnumerator *state=[dictionary keyEnumerator];
   id            key,object,keys[count],objects[count];

   for(i=0;(key=[state nextObject])!=nil;i++){
    object=[dictionary objectForKey:key];

    keys[i]=key;
    objects[i]=object;
   }

   return [self initWithObjects:objects forKeys:keys count:count];
}

-initWithDictionary:(NSDictionary *)dictionary copyItems:(BOOL)copyItems {
   NSUnimplementedMethod();
   return nil;
}

-initWithObjectsAndKeys:first,... {
   va_list  arguments;
   unsigned i,count;
   id      *objects,*keys;

   va_start(arguments,first);
   count=1;
   while(va_arg(arguments,id)!=nil)
    count++;
   va_end(arguments);

   objects=__builtin_alloca(sizeof(id)*count/2);
   keys=__builtin_alloca(sizeof(id)*count/2);

   va_start(arguments,first);
   objects[0]=first;
   keys[0]=va_arg(arguments,id);

   for(i=1;i<count/2;i++){
    objects[i]=va_arg(arguments,id);
    keys[i]=va_arg(arguments,id);
   }

   va_end(arguments);

   return [self initWithObjects:objects forKeys:keys count:count/2];
}

-initWithContentsOfFile:(NSString *)path {
   NSDictionary *contents=[NSPropertyListReader dictionaryWithContentsOfFile:path];

   if(contents==nil){
    [self dealloc];
    return nil;
   }

   return [self initWithDictionary:contents];
}

-initWithContentsOfURL:(NSURL *)url {
   if(![url isFileURL]){
    [self dealloc];
    return nil;
   }
   
   return [self initWithContentsOfFile:[url path]];
}

+dictionary {
   return [[[self allocWithZone:NULL] init] autorelease];
}

+dictionaryWithObjects:(NSArray *)objects forKeys:(NSArray *)keys {
   return [[[self allocWithZone:NULL] initWithObjects:objects forKeys:keys] autorelease];
}


+dictionaryWithObjects:(id *)objects forKeys:(id *)keys count:(unsigned)count {
   return [[[self allocWithZone:NULL] initWithObjects:objects forKeys:keys count:count] autorelease];
}


+dictionaryWithDictionary:(NSDictionary *)other {
   return [[[self allocWithZone:NULL] initWithDictionary:other] autorelease];
}

+dictionaryWithObjectsAndKeys:first,... {
   va_list  arguments;
   unsigned i,count;
   id      *objects,*keys;

   va_start(arguments,first);
   count=1;
   while(va_arg(arguments,id)!=nil)
    count++;
   va_end(arguments);

   objects=__builtin_alloca(sizeof(id)*count/2);
   keys=__builtin_alloca(sizeof(id)*count/2);

   va_start(arguments,first);
   objects[0]=first;
   keys[0]=va_arg(arguments,id);

   for(i=1;i<count/2;i++){
    objects[i]=va_arg(arguments,id);
    keys[i]=va_arg(arguments,id);
   }

   va_end(arguments);

   return [[[self allocWithZone:NULL]
     initWithObjects:objects forKeys:keys count:count/2] autorelease];
}

+dictionaryWithObject:object forKey:key {
   return [[[self allocWithZone:NULL] initWithObjects:&object forKeys:&key count:1] autorelease];
}

+dictionaryWithContentsOfFile:(NSString *)path {
   return [[[self allocWithZone:NULL] initWithContentsOfFile:path] autorelease];
}

+dictionaryWithContentsOfURL:(NSURL *)url {
   return [[[self allocWithZone:NULL] initWithContentsOfURL:url] autorelease];
}


-copy {
   return [self retain];
}

-copyWithZone:(NSZone *)zone {
   return [self retain];
}

-mutableCopy {
   return [[NSMutableDictionary allocWithZone:NULL] initWithDictionary:self];
}

-mutableCopyWithZone:(NSZone *)zone {
   return [[NSMutableDictionary allocWithZone:zone] initWithDictionary:self];
}

-(Class)classForCoder {
   return OBJCClassFromString("NSDictionary");
}

-initWithCoder:(NSCoder *)coder {
   if([coder isKindOfClass:[NSKeyedUnarchiver class]]){
    NSKeyedUnarchiver *keyed=(NSKeyedUnarchiver *)coder;
    NSArray           *keys=[keyed decodeObjectForKey:@"NS.keys"];
    NSArray           *objects=[keyed decodeObjectForKey:@"NS.objects"];
    
    return [self initWithObjects:objects forKeys:keys];
   }
   else {
    unsigned i,count;
    id      *keys,*values;

    [coder decodeValueOfObjCType:@encode(int) at:&count];
    keys=__builtin_alloca(count*sizeof(id));
    values=__builtin_alloca(count*sizeof(id));

    for(i=0;i<count;i++){
     keys[i]=[coder decodeObject];
     values[i]=[coder decodeObject];
    }

    return [self initWithObjects:values forKeys:keys count:count];
   }
}

-(void)encodeWithCoder:(NSCoder *)coder {
   NSEnumerator *state=[self keyEnumerator];
   unsigned      count=[self count];
   id            key;

   [coder encodeValueOfObjCType:@encode(int) at:&count];

   while((key=[state nextObject])!=nil){
    id value=[self objectForKey:key];

    [coder encodeObject:key];
    [coder encodeObject:value];
   }
}

-objectForKey:key {
   NSInvalidAbstractInvocation();
   return nil;
}

-(unsigned)count {
   NSInvalidAbstractInvocation();
   return 0;
}

-(NSEnumerator *)keyEnumerator {
   NSInvalidAbstractInvocation();
   return nil;
}

-(NSEnumerator *)objectEnumerator {
   return [[[NSEnumerator_dictionaryObjects allocWithZone:NULL]
                             initWithDictionary:self] autorelease];
}

-(void)getObjects:(id *)objects andKeys:(id *)keys {
   NSEnumerator *state=[self keyEnumerator];
   id            key;
   NSInteger     i;
   
   for(i=0;(key=[state nextObject])!=nil;i++){
    id value=[self objectForKey:key];
    
    objects[i]=value;
    keys[i]=key;
   }
}

-(unsigned)hash {
   return [self count];
}

-(BOOL)isEqual:other {
   if(self==other)
    return YES;

   if(![other isKindOfClass:OBJCClassFromString("NSDictionary")])
    return NO;

   return [self isEqualToDictionary:other];
}

-(BOOL)isEqualToDictionary:(NSDictionary *)dictionary {
   NSEnumerator *keys;
   id            key;

   if(self==dictionary)
    return YES;

   if([self count]!=[dictionary count])
    return NO;

   keys=[self keyEnumerator];
   while((key=[keys nextObject])!=nil){
    id value=[self objectForKey:key];
    id otherValue=[dictionary objectForKey:key];

    if(otherValue==nil)
     return NO;
    if(![value isEqual:otherValue])
     return NO;
   }

   return YES;   
}

-(NSArray *)allKeys {
   int i,count=[self count];
   id keys[count],obj;
   NSEnumerator *state=[self keyEnumerator];

   for(i=0;(obj=[state nextObject])!=nil;i++)
    keys[i]=obj;

   return [[[NSArray allocWithZone:NULL] initWithObjects:keys count:count] autorelease];
}

-(NSArray *)allKeysForObject:object {
   NSMutableArray *result=[NSMutableArray array];
   NSEnumerator   *state=[self keyEnumerator];
   id              key;

   while((key=[state nextObject])!=nil){
    id check=[self objectForKey:key];

    if(check==object)
     [result addObject:key];
   }

   return result;
}

- (NSArray *) keysSortedByValueUsingSelector: (SEL)selector 
        { // there is probably a faster implementation, but at least this is easy to understand. 
        NSMutableArray * result = nil; 
        NSAutoreleasePool * pool = [NSAutoreleasePool new]; 
        NSArray * values = [[self allValues] sortedArrayUsingSelector: selector]; 
        id value; 
        NSEnumerator * de = [values objectEnumerator]; 
        result = [NSMutableArray array]; 
        while((value = [de nextObject])) 
                { 
                [result addObjectsFromArray: [self allKeysForObject: value]]; 
                } 
        result = [result copy]; 
        [pool release]; 
        return [result autorelease]; 
        } 

-(NSArray *)allValues {
   int i,count=[self count];
   id values[count],obj;
   NSEnumerator *state=[self keyEnumerator];

   for(i=0;(obj=[state nextObject])!=nil;i++)
    values[i]=[self objectForKey:obj];

   return [[[NSArray allocWithZone:NULL] initWithObjects:values count:count] autorelease];
}

-(NSArray *)objectsForKeys:(NSArray *)keys notFoundMarker:marker {
   NSMutableArray *result=[NSMutableArray arrayWithCapacity:[keys count]];
   int             i,count=[keys count];

   for(i=0;i<count;i++){
    id object=[self objectForKey:[keys objectAtIndex:i]];

    if(object==nil)
     object=marker;

    [result addObject:object];
   }

   return result;
}

-(BOOL)writeToFile:(NSString *)path atomically:(BOOL)atomically {
   return [NSPropertyListWriter_vintage writePropertyList:self toFile:path atomically:atomically];
}

-(BOOL)writeToURL:(NSURL *)url atomically:(BOOL)atomically {
   if([url isFileURL])
    return [self writeToFile:[url path] atomically:atomically];
   
   return NO;
}

-(NSString *)description {
   return [NSPropertyListWriter_vintage stringWithPropertyList:self];
}

-(NSString *)descriptionInStringsFileFormat {
   NSUnimplementedMethod();
   return nil;
}

-(NSString *)descriptionWithLocale:locale {
   NSUnimplementedMethod();
   return nil;
}

-(NSString *)descriptionWithLocale:locale indent:(unsigned)indent {
   NSUnimplementedMethod();
   return nil;
}


@end


