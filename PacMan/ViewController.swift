//
//  ViewController.swift
//  PacMan
//
//  Created by Michael Holst on 23/06/15.
//  Copyright (c) 2015 Michael Holst. All rights reserved.
//

import UIKit


class ViewController: UIViewController {
    @IBOutlet weak var timer_label: UILabel!
    @IBOutlet weak var pacman: UIImageView!
    @IBOutlet var walls: [UIImageView]!
    @IBOutlet weak var blueghost_1: UIImageView!
    @IBOutlet weak var blueghost_2: UIImageView!
    @IBOutlet weak var redghost_1: UIImageView!
    @IBOutlet weak var redghost_2: UIImageView!
    @IBOutlet weak var target: UIImageView!
    @IBOutlet weak var points_label: UILabel!
    
    var timer = NSTimer()
    var ghost_timer = NSTimer()
    
    // setzen der globalen Variablen
    struct MyGlobalVariables {
        static var timer_counter     = 1200;
        static var ghost_counter     = 10;
        static var move_speed_blue_1 = 10;
        static var move_speed_blue_2 = 10;
        static var move_speed_red_1  = 10;
        static var move_speed_red_2  = 10;
        static var points            = 0;
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        timer_label.font = timer_label.font.fontWithSize(12)
        points_label.font = points_label.font.fontWithSize(12)
        points_label.text = "Points: "
        start();
        
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //Spielschleife zum Abfragen von veränderbaren Zuständen
    func gameloop(){
        timer_count()
        moveGhosts()
        
        if(collisionMovingObjects(pacman, check_image_2: redghost_1)){
            pacman_restart()
            MyGlobalVariables.timer_counter = MyGlobalVariables.timer_counter + -250
        }
        
        if(collisionMovingObjects(pacman, check_image_2: redghost_2)){
            pacman_restart()
            MyGlobalVariables.timer_counter = MyGlobalVariables.timer_counter - 250
        }
        
        if(collisionMovingObjects(pacman, check_image_2: blueghost_1)){
            blue_ghost_die(blueghost_1)
            start_ghost_timer()
            MyGlobalVariables.timer_counter = MyGlobalVariables.timer_counter + 100
            MyGlobalVariables.points = MyGlobalVariables.points + 100
        }
        
        if(collisionMovingObjects(pacman, check_image_2: blueghost_2)){
            blue_ghost_die(blueghost_2)
            start_ghost_timer()
            MyGlobalVariables.timer_counter = MyGlobalVariables.timer_counter + 100
            MyGlobalVariables.points = MyGlobalVariables.points + 100
        }
        
        if(collisionMovingObjects(pacman, check_image_2: target)){
            pacman_restart()
            MyGlobalVariables.points = MyGlobalVariables.points + 10
        }
        
        points_label.text = "Points: " + String(MyGlobalVariables.points)
        
        if(timer_count()){
            stop_timer()
            showAlert()
        }
        
        
    }
    
    //Anzeigen des Alerts am Spielende und zurücksetzen der Variablen
    func showAlert(){
        let alertController = UIAlertController(title: "GameOver", message: "Du hast "+String(MyGlobalVariables.points) + " Punkte erreicht", preferredStyle: .Alert)
        
        let defaultAction = UIAlertAction(title: "OK", style: .Default, handler: { (GameReset) -> Void in
            MyGlobalVariables.points = 0
            MyGlobalVariables.timer_counter = 1200
            MyGlobalVariables.ghost_counter = 10
            self.blueghost_1.center.x = 281
            self.blueghost_1.center.y = 284
            self.blueghost_2.center.x = 280
            self.blueghost_2.center.y = 56
            self.pacman_restart()
            self.start()
            })
        alertController.addAction(defaultAction)
        
        presentViewController(alertController, animated: true, completion: nil)
    }
    
    //Start für den Timer des Gameloops
    func start() {
        NSLog("Timer gestartet")
        timer = NSTimer.scheduledTimerWithTimeInterval(0.2, target: self, selector: Selector("gameloop"), userInfo: nil, repeats: true)
    }
    
    //Stoppen der beiden Timer
    func stop_timer() {
        timer.invalidate()
        ghost_timer.invalidate()
    }
    
    //Start für den Timer des ghost_timer_count
    func start_ghost_timer(){
        NSLog("Timer gestartet")
        ghost_timer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: Selector("ghost_timer_count"), userInfo: nil, repeats: true)
        
    }
    
    //Zeit-Counter für Spielzeit
    func timer_count() -> Bool{
        MyGlobalVariables.timer_counter = MyGlobalVariables.timer_counter-1
        timer_label.text = "Zeit: " + String((MyGlobalVariables.timer_counter/10))
        if(MyGlobalVariables.timer_counter <= 0){
            return true
        }
        return false
    }
    
    //Zeit-Couter für Geister Respawn
    func ghost_timer_count () {
        MyGlobalVariables.ghost_counter = MyGlobalVariables.ghost_counter-1
        if(MyGlobalVariables.ghost_counter == 0){
            
            MyGlobalVariables.ghost_counter = 10
            ghost_timer.invalidate()
            NSLog("WIEDER DA")
            blueghost_1.center.x = 281
            blueghost_1.center.y = 284
            
            blueghost_2.center.x = 280
            blueghost_2.center.y = 56
        }
    }
    
    //Pacman an den Start setzen
    func pacman_restart(){
        pacman.center.x = 205;
        pacman.center.y = 540;
    }
    
    //Blauen Geist aus Bild schieben
    func blue_ghost_die(ghost: UIImageView){
        ghost.center.x = -10;
        ghost.center.y = -540;
    }
    
    //Kollisionsabfrage mit Wand
    func collsisionWall(check_image: UIImageView, offset: CGPoint) ->Bool{
        
        let check_rect: CGRect = CGRectMake(check_image.center.x-check_image.bounds.width/2+offset.x, check_image.center.y-check_image.bounds.height/2+offset.y, check_image.bounds.width, check_image.bounds.height)
        
        for wall in walls{
            let wall_rect: CGRect = CGRectMake(wall.center.x-40, wall.center.y-40, 80, 80)
            
            if(CGRectIntersectsRect(check_rect, wall_rect)){
                return true
            }
        }
        return false
    }
    
    //Kollisionsabfrage mit Rand
    func collisionBorder(check_image: UIImageView, offset: CGPoint) ->Bool {
        
        let left_border: CGRect = CGRectMake(0,0, 1, 570)
        let right_border: CGRect = CGRectMake(320,0,1,570)
        let bottom_border: CGRect = CGRectMake(0,570,320,1)
        let top_border: CGRect = CGRectMake(0,0,320,1)
        
        let check_rect: CGRect = CGRectMake(check_image.center.x-check_image.bounds.width/2+offset.x, check_image.center.y-check_image.bounds.height/2+offset.y, check_image.bounds.width, check_image.bounds.height)
        
        if(CGRectIntersectsRect(check_rect, left_border)){
            return true
        }
        else if(CGRectIntersectsRect(check_rect, right_border)){
            return true
        }
        else if(CGRectIntersectsRect(check_rect, bottom_border)){
            return true
        }
        else if(CGRectIntersectsRect(check_rect, top_border)){
            return true
        }
        return false
    }
    
    //Kollisionsabfrage für 2 bewegte Objekte
    func collisionMovingObjects(check_image_1: UIImageView, check_image_2: UIImageView) -> Bool{
        
        let check_rect_1: CGRect = CGRectMake(check_image_1.center.x-check_image_1.bounds.width/2, check_image_1.center.y-check_image_1.bounds.height/2, check_image_1.bounds.width-5, check_image_1.bounds.height-5)
        
        let check_rect_2: CGRect = CGRectMake(check_image_2.center.x-check_image_2.bounds.width/2, check_image_2.center.y-check_image_2.bounds.height/2, check_image_2.bounds.width-5, check_image_2.bounds.height-5)
        
        if(CGRectIntersectsRect(check_rect_1, check_rect_2)){
            NSLog("KOllision")
            return true
        }
        return false
        
    }
    
    //Automatische Bewegung der Geister
    func moveGhosts(){
        
        //Blauer Geist 1 von Links nach Rechts Richtungswechsel
        if(collisionBorder(blueghost_1, offset: CGPointMake(0, 0))){
            MyGlobalVariables.move_speed_blue_1 = MyGlobalVariables.move_speed_blue_1 * -1;
        }
        
        //Blauer Geist 2 von Oben nach Unten Richtungswechsel
        if(collisionBorder(blueghost_2, offset: CGPointMake(0, 0))){
            MyGlobalVariables.move_speed_blue_2 = MyGlobalVariables.move_speed_blue_2 * -1;
        }else if(collsisionWall(blueghost_2, offset: CGPointMake(0, 0))){
        MyGlobalVariables.move_speed_blue_2 = MyGlobalVariables.move_speed_blue_2 * -1;
        }
        
        //Roter Geist 1 von Oben nach Unten Richtungswechsel
        if(collisionBorder(redghost_1, offset: CGPointMake(0, 0))){
            MyGlobalVariables.move_speed_red_1 = MyGlobalVariables.move_speed_red_1 * -1;
        }else if(collsisionWall(redghost_1, offset: CGPointMake(0, 0))){
            MyGlobalVariables.move_speed_red_1 = MyGlobalVariables.move_speed_red_1 * -1;
        }
        
        //Roter Geist 2 von Oben nach Unten Richtungswechsel
        if(collisionBorder(redghost_2, offset: CGPointMake(0, 0))){
            MyGlobalVariables.move_speed_red_2 = MyGlobalVariables.move_speed_red_2 * -1;
        }else if(collsisionWall(redghost_2, offset: CGPointMake(0, 0))){
            MyGlobalVariables.move_speed_red_2 = MyGlobalVariables.move_speed_red_2 * -1;
        }
        
        
        blueghost_1.center.x = blueghost_1.center.x + CGFloat(MyGlobalVariables.move_speed_blue_1)
        
        blueghost_2.center.y = blueghost_2.center.y + CGFloat(MyGlobalVariables.move_speed_blue_2)
        
        redghost_1.center.y = redghost_1.center.y + CGFloat(MyGlobalVariables.move_speed_red_1)
        
        redghost_2.center.y = redghost_2.center.y + CGFloat(MyGlobalVariables.move_speed_red_2)
    }
    
    //Eingabefunktionen für die Buttons
    @IBAction func left(sender: AnyObject) {
        let point: CGPoint = CGPointMake(-10, 0)
        if(!(collsisionWall(pacman, offset: point) || collisionBorder(pacman, offset: point))){
            pacman.center.x = pacman.center.x-10
        }
    }
    @IBAction func down(sender: AnyObject) {
        let point: CGPoint = CGPointMake(0, 10)
        if(!(collsisionWall(pacman, offset: point) || collisionBorder(pacman, offset: point))){
        pacman.center.y = pacman.center.y+10
        }
    }
    @IBAction func up(sender: AnyObject) {
        let point: CGPoint = CGPointMake(0, -10)
        if(!(collsisionWall(pacman, offset: point) || collisionBorder(pacman, offset: point))){
        pacman.center.y = pacman.center.y-10
        }
    }
    @IBAction func right(sender: AnyObject) {
        let point: CGPoint = CGPointMake(10, 0)
        if(!(collsisionWall(pacman, offset: point) || collisionBorder(pacman, offset: point))){
        pacman.center.x = pacman.center.x+10
        }
    }
    
    
    
  
    

    

}

