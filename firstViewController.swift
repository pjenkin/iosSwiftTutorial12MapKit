//
//  firstViewController.swift
//  Travel Map
//
//  Created by Peter Jenkin on 08/04/2019.
//  Copyright © 2019 Peter Jenkin. All rights reserved.
//

import UIKit
import CoreData

class firstViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    
    @IBOutlet weak var tableView: UITableView!
    
    var titleArray = [String]()
    var subtitleArray = [String]()
    var latitudeArray = [Double]()
    var longitudeArray = [Double]()
    
    // cf ViewController for chosen... transmitted... variable correspondence for passing data between ViewControllers
    var chosenTitle = ""
    var chosenSubtitle = ""
    var chosenLatitude = 0.0
    var chosenLongitude = 0.0

    
    override func viewDidLoad() {
 
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        tableView.delegate = self
        tableView.dataSource = self
        
        fetchData()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    // bespoke function
    func fetchData()
    {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        // NB autocomplete trying to write AppDelegate not appDelegate
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Locations")
        // cf Entity entry in Travel_Map.xcdatamodeld
        // NB add <NSFetchRequestResult> template specifier manually - ensure autocomplete doesn't pick wrong one!
        request.returnsObjectsAsFaults = false
        do
        {
            let results = try context.fetch(request)
            if results.count > 0
            {
                // clear all arrays
                self.titleArray.removeAll(keepingCapacity: false)
                self.subtitleArray.removeAll(keepingCapacity: false)
                self.latitudeArray.removeAll(keepingCapacity: false)
                self.longitudeArray.removeAll(keepingCapacity: false)
                
                
                for result in results as! [NSManagedObject]
                {
                    if let title = result.value(forKey: "title") as? String
                    {
                            self.titleArray.append(title)
                    }
                    if let subtitle = result.value(forKey: "subtitle") as? String
                    {
                        self.subtitleArray.append(subtitle)
                    }
                    if let latitude = result.value(forKey: "latitude") as? Double
                    {
                        self.latitudeArray.append(latitude)
                    }
                    if let longitude = result.value(forKey: "longitude") as? Double
                    {
                        self.longitudeArray.append(longitude)
                    }
                    print("got here")
                        self.tableView.reloadData() // refresh table view with retrieved results

                }
            }
        }
        catch
        {
            
        }
    }
    
    
// delegates added for tableView
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // return 5        // 5 rows, say
        return titleArray.count     // however many as are in the titleArray
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        //cell.textLabel?.text = "checking text"
        cell.textLabel?.text = titleArray[indexPath.row]
        return cell
    }
    
// additional delegate for when a tableView row (ie location title) selected
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        chosenTitle = titleArray[indexPath.row]     // pass over data to other ViewController (ie the map view)
        chosenSubtitle = subtitleArray[indexPath.row]
        chosenLatitude = Double(latitudeArray[indexPath.row])
        chosenLongitude = Double(longitudeArray[indexPath.row])
        
        performSegue(withIdentifier: "toMapVC", sender: nil)
        // aha! I missed this line in video but guessed later
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toMapVC"
        {
            let destinationVC = segue.destination as! ViewController
            // pass over/transmit data to the other ViewController
            destinationVC.transmittedTitle = self.chosenTitle
            destinationVC.transmittedSubtitle = self.chosenSubtitle
            destinationVC.transmittedLatitude = self.chosenLatitude
            destinationVC.transmittedLongitude = self.chosenLongitude
        }
    }
    
    
    @IBAction func addBtnClicked(_ sender: Any) {
        performSegue(withIdentifier: "toMapVC", sender: nil)
    }
    
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
