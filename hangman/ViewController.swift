//
//  ViewController.swift
//  hangman
//
//  Created by Marina Khort on 01.09.2020.
//  Copyright © 2020 Marina Khort. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
	var words: [String] = []
	var letterButtons = [UIButton]()	//list of our buttons with letters
	var numberLabel: UILabel!			//words passed
	var livesRemainLabel: UILabel!
	var answerWord: UITextField!		//that what user entered
	
	var guessedLetter: String = ""		//the letter entered by player
	var guessedGameWord = ""			//the word which is right and we need to tape it in
	var currentWord: String = ""		//game word string
	var rightUsedLetters = ""			//letters we typed and which are right

	var number = 0 {
		didSet {
			numberLabel.text = "\(number+1) / 9"
		}
	}
	var lives = 7 {
		didSet {
			livesRemainLabel.text = "\(lives) lives remaining"
		}
	}

	override func loadView() {
		view = UIView()
		view.frame = UIScreen.main.bounds
		let imageBack = UIImageView()
		imageBack.image = UIImage(named: "backgroundColorFall")
		imageBack.frame = view.bounds
		imageBack.contentMode = .scaleAspectFill
		imageBack.clipsToBounds = true
		view.addSubview(imageBack)
		
		numberLabel = UILabel()
		numberLabel.translatesAutoresizingMaskIntoConstraints = false
		numberLabel.font = UIFont.systemFont(ofSize: 24)
		numberLabel.textAlignment = .right
		numberLabel.textColor = .darkGray
		numberLabel.text = "\(number) / 9"
		view.addSubview(numberLabel)
		
		livesRemainLabel = UILabel()
		livesRemainLabel.translatesAutoresizingMaskIntoConstraints = false
		livesRemainLabel.font = UIFont.systemFont(ofSize: 18)
		livesRemainLabel.textAlignment = .right
		livesRemainLabel.textColor = .darkGray
		livesRemainLabel.text = "7 lives left"
		view.addSubview(livesRemainLabel)
		
		answerWord = UITextField()
		answerWord.translatesAutoresizingMaskIntoConstraints = false
		answerWord.font = UIFont.systemFont(ofSize: 42)
		answerWord.textColor = .orange
		answerWord.textAlignment = .center
		answerWord.isUserInteractionEnabled = false
		answerWord.placeholder = ""
		view.addSubview(answerWord)
				
		let buttonsView = UIView()
		buttonsView.translatesAutoresizingMaskIntoConstraints = false
		view.addSubview(buttonsView)
		
		//constraints
		NSLayoutConstraint.activate([
			imageBack.topAnchor.constraint(equalTo: view.topAnchor),
			imageBack.trailingAnchor.constraint(equalTo: view.trailingAnchor),
			imageBack.leadingAnchor.constraint(equalTo: view.leadingAnchor),
			imageBack.bottomAnchor.constraint(equalTo: view.bottomAnchor),
			
			numberLabel.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor,constant: 10),
			numberLabel.rightAnchor.constraint(equalTo: view.layoutMarginsGuide.rightAnchor,constant: -10),
			
			answerWord.centerXAnchor.constraint(equalTo: view.centerXAnchor),
			answerWord.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.5),
			answerWord.topAnchor.constraint(equalTo: numberLabel.bottomAnchor, constant: 100),
			
			livesRemainLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
			livesRemainLabel.topAnchor.constraint(equalTo: answerWord.bottomAnchor, constant: 20),
			
			buttonsView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
			buttonsView.topAnchor.constraint(equalTo: answerWord.bottomAnchor, constant: 50),
			buttonsView.bottomAnchor.constraint(equalTo: view.layoutMarginsGuide.bottomAnchor, constant:  -20),
			buttonsView.widthAnchor.constraint(equalToConstant: 360),
			buttonsView.heightAnchor.constraint(equalToConstant: 550)
		])
		
		//make buttons view
		let width = 60
		let height = 80
		
		for row in 0..<3 {
			for col in 0..<6 {
				let letterButton = UIButton(type: .system)
				letterButton.setTitle("L", for: .normal)
				letterButton.titleLabel?.font = UIFont.systemFont(ofSize: 36)
				letterButton.setTitleColor(.black, for: .normal)
				
				let frame = CGRect(x: col * width, y: row * height, width: width, height: height)
				letterButton.frame = frame
				
				buttonsView.addSubview(letterButton)
				letterButtons.append(letterButton)
				letterButton.addTarget(self, action: #selector(letterTapped), for: .touchUpInside)
			}
		}
		self.words = loadWords()
	}
	
	
	override func viewDidLoad() {
		super.viewDidLoad()
		performSelector(inBackground: #selector(loadWords), with: nil)
		startGame()
	}
	

	func startGame() {
		configureLetters(word: words[number])
	}
	
	@objc func loadWords() -> [String] {
		var words = [String]()
		
		if let levelURL = Bundle.main.url(forResource: "hangman", withExtension: "txt") {
			if let levelContent = try? String(contentsOf: levelURL) {
				words = levelContent.components(separatedBy: "\n")
				words.shuffle()
			}
		}
		return words
	}
	
	
	@objc func letterTapped(_ sender: UIButton) {
		guard let letterTitle = sender.titleLabel?.text else {return}
		guessedLetter = letterTitle
		sender.isEnabled = false
		sender.backgroundColor = .orange
		gameplay()
		if guessedGameWord == currentWord {
			nextWord()
		}
	}
	
	
	func configureLetters(word: String) {
		var uniqLetters = [Character]()
		let wordInChars = Array(word)
		currentWord = word
		let allLettersInWords = Array(words.joined())
		
		
		//make uniq letters array for buttons
		for i in allLettersInWords {
			if uniqLetters.contains(i) == false {
				uniqLetters.append(i)
			}
		}
		uniqLetters.shuffle()
		
		//adjust buttons
		for i in 0 ..< letterButtons.count {
			letterButtons[i].setTitle(String(uniqLetters[i]), for: .normal)
		}
		createUnderscores(wordChars: wordInChars)
		
		print(currentWord)
	}
	
	
	func createUnderscores(wordChars: [Character]) {
		for _ in wordChars {
			answerWord.text! += " _ "
		}
	}
	
	func gameplay() {
		if currentWord.contains(guessedLetter) {
			rightUsedLetters.append(guessedLetter)
			guessedGameWord = currentWord.map {rightUsedLetters.contains(String($0)) ? String($0) : " _ "}.joined()
			answerWord.text = guessedGameWord
		} else {
			print("wrong word")
			lives -= 1
			if lives == 0 {
				failGame()
			}
			
		}
		print(rightUsedLetters)
	}
	
	
	func failGame() {
		let ac = UIAlertController(title: "You failed", message: "But you can try again", preferredStyle: .alert)
		ac.addAction(UIAlertAction(title: "Again", style: .cancel, handler: reloadData))
		present(ac, animated: true)
	}
	
	
	func reloadData(action: UIAlertAction) {
		lives = 7
		clear()
		createUnderscores(wordChars: Array(currentWord))
	}
	
	func clear() {
		guessedGameWord.removeAll()
		answerWord.text = ""
		rightUsedLetters.removeAll()
		for buttons in letterButtons {
			buttons.backgroundColor = .none
			buttons.isEnabled = true
		}
		
	}
	
	func nextWord() {
		if number == 9 {
			number = 0
		} else {
			number += 1
		}
		clear()
		let nextWord = words[number]
		configureLetters(word: nextWord)
	}
}

