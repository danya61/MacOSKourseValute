//
//  ViewController.swift
//  MoneyKurse
//
//  Created by Danya on 24.12.16.
//  Copyright © 2016 Danya. All rights reserved.
//

import Cocoa
import Darwin

extension String {
    mutating func replace(_ originalString:String, with newString:String) {
        self = self.replacingOccurrences(of: originalString, with: newString)
    }
}

class ViewController: NSViewController, XMLParserDelegate {

    
    @IBOutlet weak var kourseLabel: NSTextField!
    
    var money : Double?
    var myparser = XMLParser()
    var element = NSString()
    var arr  = [String: Double]()
    var name : NSString?
    var value : NSString?
    var text = ""
    var val = ""
    var date = Date()
    
    var pDict : NSDictionary?
    
    var topArr = [Int : [String:Double]]()
    var ind : Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let path = Bundle.main.path(forResource: "my", ofType: "plist") {
            pDict = NSDictionary(contentsOfFile: path)
        }
        print(pDict!)
        ind = 0;
        for i in 0...6 {
            let calendar = Calendar.current
            date = calendar.date(byAdding: .day, value: -i, to: Date())!
            let formatter = DateFormatter()
            formatter.dateFormat = "dd.MM.yyyy"
            
            let res = formatter.string(from: date)
        
            myparser = XMLParser(contentsOf: URL(string: "https://www.cbr.ru/scripts/XML_daily.asp?date_req=" + res)!)!
            myparser.delegate = self
            if myparser.parse() {
                topArr.updateValue(arr, forKey: i)
            }
        }
        
        for (i,j) in topArr {
            //print("\(i) --- \(j) \n\n\n")
        }
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }

    @IBAction func ButtonPressed(_ sender: Any) {
        var kr : String = "Курс ЦБ на сегодня: \n"
        for (i, j) in topArr {
            if i == 0 {
                for (nm, vl) in j {
                    kr += "\(nm)  -    \(vl) \n"
                }
            }
        }
        kourseLabel.stringValue = kr
        
        /* var names = [String](arr.keys)
       // print(names.count)
        var middleMin = [Double]()
        var cur_mat = [[Double]]()
        //мат ожидание доходности
        for i in 0...names.count - 1 {
            var ind = 5
            var kf = [Double]()
            for j in 0...5 {
                var arr2 = topArr[j + ind]
                var arr3 = topArr[j + 1 + ind]
                ind -= 1
                kf.append( Double(((arr2?[names[i]])! - (arr3?[names[i]]!)!) / (arr3?[names[i]]!)!) )
            }
            cur_mat.append(kf)
            var sum : Double = 0
            for f in kf {
               sum += f
            }
            middleMin.append(sum) //мат ожидание записано
        }

        //print(middleMin)
        //дисперсия - риск
        var Disp = [Double]()
        var indd = 0
        for cur in cur_mat {
            var sum : Double = 0
            for i in cur {
                sum += Double(pow(i,2) - middleMin[indd])
            }
            indd+=1
            sum /= 6
            Disp.append(sum)
        }
       
        let memoryName = pDict?["0"] as! NSDictionary
        var s : String = ""
        for i in 0...32 {
            var db = NSString(string: (memoryName[String(i)] as? String)!).doubleValue
            print(db)
            print(money!)
            let temp  = db * money!
            db = Double( temp / 100)
            s += "\(names[i])   =  \(db) \n"
        } */
 
        
    }
    
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        element = elementName as NSString
        if element.isEqual(to: "Valute"){
            name = ""
            value = ""
        }
    }
    
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        if (element as NSString).isEqual(to: "Name") {
            name = string as NSString?
            text += name as! String
        } else
        if (element as NSString).isEqual(to: "Value") {
            value = string as NSString?
            val += value  as! String
        }
        
    }
    
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        if element.isEqual(to: "Valute") {
        
            
        }
    }

    func parserDidEndDocument(_ parser: XMLParser) {
        if ind < 7 {
            var t = text.components(separatedBy: "\n\t")
            t.removeLast()
    
            var s = val.components(separatedBy: "\n\n")
            for (i) in 0...s.count - 1 {
                s[i].replace(",", with: ".")
            }
            for (i,j) in zip(t,s) {
                arr.updateValue((j as NSString).doubleValue, forKey: (i as String?)!)
            }
            ind += 1
            //print("\(topArr) \n \n")
      }
    }
    
}

