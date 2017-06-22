//
//  ViewController.swift
//  SharedGroceries
//
//  Created by Cambium Team on 22/06/2017.
//
//

import UIKit
import Firebase

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, TableDelegate {

    var ref: FIRDatabaseReference!;
    var list: [Item]!;
    var dateFormatter: DateFormatter!;
    var diraction = false;
    @IBOutlet weak var textField: UITextField!;
    @IBOutlet weak var tableView: UITableView!;
    
    override func viewDidLoad() {
        super.viewDidLoad()
        list = [Item]();
        tableView.delegate = self;
        tableView.dataSource = self;
        dateFormatter = DateFormatter();
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss z";
        self.ref = FIRDatabase.database().reference();
        ref.observe(FIRDataEventType.childAdded) { (snapshot:FIRDataSnapshot) in
            if let dict = snapshot.value as? Dictionary<String, Any>{
                if let title = dict["title"] as? String{
                    let item = Item();
                    item.title = title;
                    if let count = dict["count"] as? Int{
                        item.count = count;
                    }
                    if let date = dict["timeStamp"] as? String{
                        item.timeStamp = self.dateFormatter.date(from: date);
                    }
                    for i in self.list{
                        if(i.title.caseInsensitiveCompare(title) == ComparisonResult.orderedSame){
                            i.title = item.title;
                            i.count = item.count;
                            i.timeStamp = item.timeStamp;
                            self.update();
                            return;
                        }
                    }
                    self.list.append(item);
                    self.update();
                }
            }
        }
        ref.observe(FIRDataEventType.childRemoved) { (snapshot:FIRDataSnapshot) in
            if let dict = snapshot.value as? Dictionary<String, Any>{
                if let title = dict["title"] as? String{
                    for i in 0..<self.list.count{
                        if(self.list[i].title.caseInsensitiveCompare(title) == ComparisonResult.orderedSame){
                            self.list.remove(at: i);
                            self.update();
                            return;
                        }
                    }
                }
            }
        }
        ref.observe(FIRDataEventType.childChanged) { (snapshot:FIRDataSnapshot) in
            if let dict = snapshot.value as? Dictionary<String, Any>{
                if let title = dict["title"] as? String{
                    let item = Item();
                    item.title = title;
                    if let count = dict["count"] as? Int{
                        item.count = count;
                    }
                    if let date = dict["timeStamp"] as? String{
                        item.timeStamp = self.dateFormatter.date(from: date);
                    }
                    for i in self.list{
                        if(i.title.caseInsensitiveCompare(title) == ComparisonResult.orderedSame){
                            i.title = item.title;
                            i.count = item.count;
                            i.timeStamp = item.timeStamp;
                            self.update();
                            return;
                        }
                    }
                    self.list.append(item);
                    self.update();
                }
            }
        }
    
    }

    @IBAction func plusButtonAction(_ sender: Any) {
        if(!(textField.text?.isEmpty)!){
            let title = textField.text!;
            for item in list {
                if(item.title.caseInsensitiveCompare(title) == ComparisonResult.orderedSame){
                    item.count! += 1;
                    self.ref.child(item.title).child("count").setValue(item.count);
                    return;
                }
            }
            let item = Item();
            item.timeStamp = Date();
            item.title = textField.text;
            item.count = 1;
            ref.child(title).child("title").setValue(title);
            ref.child(title).child("count").setValue(1);
            ref.child(title).child("timeStamp").setValue(item.timeStamp.description);
            list.append(item);
            
        }
    }
    
    func update(){
        tableView.reloadData();
    }
    
    
    func tableView(_ tableView: UITableView,
                            cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! Cell;
        var count = "";
        if let c = list[indexPath.row].count{
            count = " x\(c)";
        }
        cell.label.text = "\(list[indexPath.row].title!)\(count)";
        cell.index = indexPath.row;
        cell.delegate = self;
        return cell;
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return list.count;
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1;
    }
    
    func removeAt(index: Int!) {
        if(list[index].count > 1){
            list[index].count! -= 1;
            ref.child(list[index].title).child("count").setValue(list[index].count!);
        }
        ref.child(list[index].title).removeValue();
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func sortByTitle(){
        diraction = !diraction;
        if(diraction){
            list = list.sorted { $0.title.localizedCaseInsensitiveCompare($1.title) == ComparisonResult.orderedAscending }
        }else{
            list = list.sorted { $0.title.localizedCaseInsensitiveCompare($1.title) == ComparisonResult.orderedDescending }
        }
        update();
        update()
    }
    
    func sortByDate(){
        diraction = !diraction;
        if(diraction){
            list = list.sorted(by: { $0.timeStamp.compare($1.timeStamp) == ComparisonResult.orderedAscending })
        }else{
            list = list.sorted(by: { $0.timeStamp.compare($1.timeStamp) == ComparisonResult.orderedDescending })
        }
        update();
    }
    @IBAction func sortByTitleAction(_ sender: Any) {
        sortByTitle()
    }
    @IBAction func sortByDateAction(_ sender: Any) {
        sortByDate()
    }

}

protocol TableDelegate {
    func removeAt(index:Int!);
}

