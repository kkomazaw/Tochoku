//
//  ViewController.swift
//  Tochoku
//
//  Created by Matsui Keiji on 2018/02/27.
//  Copyright © 2018年 Matsui Keiji. All rights reserved.
//

import UIKit
import CoreData

class ViewController: UIViewController {
    
    @IBOutlet var ishiShinkiTorokuButton:UIButton!
    @IBOutlet var torokuishiIchiranButton:UIButton!
    @IBOutlet var tochokuhyouSakuseiButton:UIButton!
    @IBOutlet var hozonzumiTochokuhyoButton:UIButton!
    @IBOutlet var fukabiKiboukiButton:UIButton!
    @IBOutlet var tochokuhyoUketoriButton:UIButton!
    @IBOutlet var jujishaHozonzumiButton:UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        defaults.register(defaults: ["isSakuseisha":true,"isYushin":true,"isNicchoku":true,"isDoyoNicchoku":true])
        isSakuseisha = defaults.bool(forKey: "isSakuseisha")
        isYushin = defaults.bool(forKey: "isYushin")
        isNicchoku = defaults.bool(forKey: "isNicchoku")
        isDoyoNicchoku = defaults.bool(forKey: "isDoyoNicchoku")
        nichiyouHeijitsuDefaults.register(defaults: ["nichiyouHeijitsuString":""])
        nichiyouHeijitsuString = nichiyouHeijitsuDefaults.string(forKey: "nichiyouHeijitsuString")!
        holidayDefaults.register(defaults: ["holiday":"2021年1月1日 2021年1月2日 2021年1月3日 2021年2月11日 2021年1月11日 2021年3月20日 2021年4月29日 2021年5月3日 2021年5月4日 2021年5月5日 2021年7月22日 2021年7月23日 2021年8月8日 2021年8月9日 2021年9月20日 2021年9月23日 2021年11月3日 2021年11月23日 2021年12月31日 2022年1月1日 2022年1月2日 2022年1月3日 2022年1月10日 2022年2月11日 2022年2月23日 2022年3月21日 2022年4月29日 2022年5月3日 2022年5月4日 2022年5月5日 2022年7月18日 2022年8月11日 2022年9月19日 2022年9月23日 2022年10月10日 2022年11月3日 2022年11月23日 2022年12月31日 2023年1月1日 2023年1月2日 2023年1月3日 2023年1月9日 2023年2月11日 2023年2月23日 2023年3月21日 2023年4月29日 2023年5月3日 2023年5月4日 2023年5月5日 2023年7月17日 2023年8月11日 2023年9月18日 2023年9月23日 2023年10月9日 2023年11月3日 2023年11月23日 2023年12月31日 2024年1月1日 2024年1月2日 2024年1月3日 2024年1月8日 2024年2月12日 2024年2月23日 2024年3月20日 2024年4月29日 2024年5月3日 2024年5月4日 2024年5月6日 2024年7月15日 2024年8月12日 2024年9月16日 2024年9月23日 2024年10月14日 2024年11月4日 2024年11月23日 2024年12月31日 2025年1月1日 2025年1月2日 2025年1月3日 2025年1月13日 2025年2月11日 2025年2月24日 2025年3月20日 2025年4月29日 2025年5月3日 2025年5月5日 2025年5月6日 2025年7月21日 2025年8月11日 2025年9月15日 2025年9月23日 2025年10月13日 2025年11月3日 2025年11月24日 2025年12月31日 2026年1月1日 2026年1月2日 2026年1月3日 2026年1月12日 2026年2月11日 2026年2月23日 2026年3月20日 2026年4月29日 2026年5月4日 2026年5月5日 2026年5月6日 2026年7月20日 2026年8月11日 2026年9月21日 2026年9月22日 2026年10月12日 2026年11月3日 2026年11月23日 2026年12月31日 2027年1月1日 2027年1月2日 2027年1月3日 2027年1月11日 2027年2月11日 2027年2月23日 2027年3月22日 2027年4月29日 2027年5月3日 2027年5月4日 2027年5月5日 2027年7月19日 2027年8月11日 2027年9月20日 2027年9月23日 2027年10月11日 2027年11月3日 2027年11月23日 2027年12月31日 2028年1月1日 2028年1月2日 2028年1月3日 2028年1月10日 2028年2月11日 2028年2月23日 2028年3月20日 2028年4月29日 2028年5月3日 2028年5月4日 2028年5月5日 2028年7月17日 2028年8月11日 2028年9月18日 2028年9月22日 2028年10月9日 2028年11月3日 2028年11月23日 2028年12月31日"])
        holiday = holidayDefaults.string(forKey: "holiday")!
    }//override func viewDidLoad()

    override func viewWillAppear(_ animated: Bool) {
        var savedArray:[TochokuData] = []
        var hozonArray:[HozonData] = []
        let myContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        do{
            
            let sortDescripter = NSSortDescriptor(key: "torokubi", ascending: true)
            let sortDescripter2 = NSSortDescriptor(key: "month", ascending: true)
            let fetchRequest: NSFetchRequest<TochokuData> = TochokuData.fetchRequest()
            let fetchRequest2: NSFetchRequest<HozonData> = HozonData.fetchRequest()
            fetchRequest.sortDescriptors = [sortDescripter]
            fetchRequest2.sortDescriptors = [sortDescripter2]
            savedArray = try myContext.fetch(fetchRequest)
            hozonArray = try myContext.fetch(fetchRequest2)
        }
        catch {
            print("Fetching Failed.")
        }
        if savedArray.count == 0{
            tochokuhyouSakuseiButton.isHidden = true
        }
        else{
            tochokuhyouSakuseiButton.isHidden = false
        }
        if hozonArray.count == 0{
            hozonzumiTochokuhyoButton.isHidden = true
        }
        else{
            hozonzumiTochokuhyoButton.isHidden = false
        }
        
        if isSakuseisha{
            ishiShinkiTorokuButton.isHidden = false
            torokuishiIchiranButton.isHidden = false
            fukabiKiboukiButton.isHidden = true
            tochokuhyoUketoriButton.isHidden = true
            jujishaHozonzumiButton.isHidden = true
            if savedArray.count == 0{
                tochokuhyouSakuseiButton.isHidden = true
            }
            else{
                tochokuhyouSakuseiButton.isHidden = false
            }
            if hozonArray.count == 0{
                hozonzumiTochokuhyoButton.isHidden = true
            }
            else{
                hozonzumiTochokuhyoButton.isHidden = false
            }
        }//if isSakuseisha
        else{
            ishiShinkiTorokuButton.isHidden = true
            torokuishiIchiranButton.isHidden = true
            tochokuhyouSakuseiButton.isHidden = true
            hozonzumiTochokuhyoButton.isHidden = true
            fukabiKiboukiButton.isHidden = false
            tochokuhyoUketoriButton.isHidden = false
            jujishaHozonzumiButton.isHidden = false
        }
        
    }//override func viewWillAppear
    
    @IBAction func myActionTochokuhyoSakusei(){
        if isYushin, isNicchoku{
            self.performSegue(withIdentifier: "toSakuseiView", sender: true)
        }//if isYushin, isNicchoku
        if !isYushin, isNicchoku{
            self.performSegue(withIdentifier: "toYNNASakuseiView", sender: true)
        }//if !isYushin, isNicchoku
        if isYushin, !isNicchoku{
                self.performSegue(withIdentifier: "toNNYASakuseiView", sender: true)
        }//if isYushin, !isNicchoku
        if !isYushin, !isNicchoku{
            self.performSegue(withIdentifier: "toDNSakuseiView", sender: true)
        }//if !isYushin, !isNicchoku
    }//@IBAction func myActionTochokuhyoSakusei()
    
    @IBAction func myActionFukabiKiboubi(){
        if isYushin, isNicchoku{
            self.performSegue(withIdentifier: "toFukabiView", sender: true)
        }//if isYushin, isNicchoku
        if !isYushin, isNicchoku{
            self.performSegue(withIdentifier: "toYNNAFukabiView", sender: true)
        }//if !isYushin, isNicchoku
        if isYushin, !isNicchoku{
            self.performSegue(withIdentifier: "toNNYAFukabiView", sender: true)
        }
        if !isYushin, !isNicchoku{
            self.performSegue(withIdentifier: "toDNFukabiView", sender: true)
        }//if !isYushin, !isNicchoku
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

