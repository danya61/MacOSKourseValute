//
//  SynchronizedXMLParser.swift
//  XMLParserDemo
//
//  Created by Arthur Gevorkyan on 10.09.15.
//  No license here - just common sense :)
//

import Cocoa

class SynchronizedXMLParser: XMLParser
{
    // shared queue
    private static var _serialQueue: OperationQueue = {
        let queue = OperationQueue()
        queue.qualityOfService = QualityOfService.userInitiated
        // making it serial on purpose in order to avoid 
        // the "reentrant parsing" issue
        queue.maxConcurrentOperationCount = 1
        return queue
    }()
    
    // instance level convenience accessor
    private var _serialQueue: OperationQueue
    {
        get
        {
            return type(of: self)._serialQueue
        }
    }
    
    private weak var _associatedParsingTask: BlockOperation?
    
//MARK: - Overridden
    
    required override init(data: Data)
    {
        super.init(data: data)
    }
    
    override func parse() -> Bool
    {
        var parsingResult = false
        
        if (_associatedParsingTask == nil)
        {
            let parsingTask = BlockOperation(block: {() -> Void in
                parsingResult = super.parse()
            })
            _associatedParsingTask = parsingTask
            // making it synchronous in order to return the result 
            // of the super's parse call
            _serialQueue.addOperations([parsingTask], waitUntilFinished: true)
        }
        
        return parsingResult
    }
    
    override func abortParsing()
    {
        if let parsingTask = _associatedParsingTask
        {
            parsingTask.cancel()
            _associatedParsingTask = nil
        }
        
        super.abortParsing()
    }
    
    deinit
    {
        _associatedParsingTask?.cancel()
    }
    
}
