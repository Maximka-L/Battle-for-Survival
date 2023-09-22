import Foundation

// Класс для представления баффа
class Buff {
    let name: String
    let duration: Int
    private var remainingDuration: Int

    init(name: String, duration: Int) {
        self.name = name
        self.duration = duration
        self.remainingDuration = duration
    }

    // Метод для применения баффа к цели
    func apply(to target: Creature) {
        // Здесь можно изменять характеристики цели, например, увеличивать атаку или защиту
        print("\(name) applied to \(target.name) for \(duration) turns.")
    }

    // Метод для обновления состояния баффа на следующем ходе
    func update(target: Creature) {
        // Здесь можно обновлять состояние баффа, например, уменьшать оставшееся количество ходов
        remainingDuration -= 1
        if remainingDuration == 0 {
            expire(target: target)
        }
    }

    // Метод, вызываемый при истечении баффа
    func expire(target: Creature) {
        // Здесь можно убирать влияние баффа на характеристики цели
        print("\(name) expired on \(target.name).")
    }

    var isExpired: Bool {
        return remainingDuration <= 0
    }
}

// Класс для существа
class Creature {
    let name: String
    var attack: Int
    var defense: Int
    var health: Int
    let damageRange: ClosedRange<Int>
    private var buffs: [Buff] = [] // Список баффов

    init(name: String, attack: Int, defense: Int, health: Int, damageRange: ClosedRange<Int>) {
        self.name = name
        self.attack = max(1, min(30, attack)) // Ограничиваем атаку в диапазоне 1-30
        self.defense = max(1, min(30, defense)) // Ограничиваем защиту в диапазоне 1-30
        self.health = max(0, health) // Ограничиваем здоровье не менее 0
        self.damageRange = damageRange
    }

    func isAlive() -> Bool {
        return health > 0
    }

    func takeDamage(damage: Int) {
        guard damage >= 0 else {
            fatalError("Damage cannot be negative")
        }
        health = max(0, health - damage)
    }

    func heal() {
        let maxHeal = Int(0.3 * Double(maxHealth))
        let healAmount = Int.random(in: 1...maxHeal)
        health = min(maxHealth, health + healAmount)
    }

    func attack(target: Creature) -> String {
        let attackModifier = attack - target.defense + 1
        let diceRolls = (0..<max(attackModifier, 1)).map { _ in
            return Int.random(in: 1...6)
        }
        let successfulAttack = diceRolls.contains { roll in
            return roll == 5 || roll == 6
        }

        if successfulAttack {
            let damage = Int.random(in: damageRange)
            target.takeDamage(damage: damage)
            return "\(name) successfully attacked \(target.name) for \(damage) damage."
        } else {
            return "\(name)'s attack on \(target.name) missed."
        }
    }

    var maxHealth: Int {
        return health
    }

    // Метод для применения баффа
    func applyBuff(buff: Buff) {
        buffs.append(buff)
        buff.apply(to: self)
    }

    // Метод для обновления баффов (например, на следующем ходе)
    func updateBuffs() {
        for buff in buffs {
            buff.update(target: self)
        }
        buffs = buffs.filter { !$0.isExpired }
    }
}

// Класс для игрока
class Player: Creature {
    var isLightHammerReady: Bool = true // Флаг готовности суперсилы
    
    // Метод активации суперсилы "Световой молот"
    func activateLightHammer() {
        guard isLightHammerReady else {
            print("Световой молот еще не готов. Дождитесь восстановления.")
            return
        }
        
        // Реализация суперсилы
        let lightHammerDamage = attack * 3 // Пример: урон в 3 раза выше обычной атаки
        takeDamage(damage: lightHammerDamage * 2) // Пример: игрок теряет немного здоровья при активации суперсилы
        heal() // Пример: игрок исцеляется после активации
        
        print("Игрок активировал Световой молот и нанес огромный урон!")
        
        // Устанавливаем флаг готовности суперсилы в false
        isLightHammerReady = false
        
        // Устанавливаем таймер для восстановления суперсилы через 3 хода (пример)
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            self.isLightHammerReady = true
            print("Световой молот готов к использованию!")
        }
    }
    
    // Метод для принятия решения (атака, исцеление или активация суперсилы)
    func makeDecision() -> String {
        print("Choose your action:")
        print("1. Attack")
        print("2. Heal")
        print("3. Activate Light Hammer")
        
        while let choice = readLine() {
            switch choice {
            case "1":
                return "attack"
            case "2":
                return "heal"
            case "3":
                return "activateLightHammer"
            default:
                print("Invalid choice. Please enter 1 for Attack, 2 for Heal, or 3 to Activate Light Hammer.")
            }
        }
        
        // Добавим возврат по умолчанию в случае, если не удалось получить корректный ввод
        return ""
    }
}

// Класс для монстра
class Monster: Creature {
    let specialAbility: String
    var isEnraged: Bool

    init(name: String, attack: Int, defense: Int, health: Int, damageRange: ClosedRange<Int>, specialAbility: String) {
        self.specialAbility = specialAbility
        self.isEnraged = false
        super.init(name: name, attack: attack, defense: defense, health: health, damageRange: damageRange)
    }

    func becomeEnraged() {
        isEnraged = true
        attack += 5
        print("\(name) becomes enraged! Attack increased.")
    }
}

func main() {
    // Создаем игрока и монстра
    let player = Player(name: "Player", attack: 10, defense: 5, health: 100, damageRange: 10...20)
    let monster = Monster(name: "Monster", attack: 8, defense: 3, health: 80, damageRange: 8...15, specialAbility: "Enrage")

    // Создаем баффы
    let attackBuff = Buff(name: "Attack Boost", duration: 3)
    let defenseBuff = Buff(name: "Defense Boost", duration: 2)

    // Применяем баффы к игроку и монстру
    player.applyBuff(buff: attackBuff)
    monster.applyBuff(buff: defenseBuff)

    // Симулируем бой
    while player.isAlive() && monster.isAlive() {
        print("Player's turn:")
        let playerDecision = player.makeDecision()

        switch playerDecision {
        case "attack":
            print(player.attack(target: monster))
        case "heal":
            player.heal()
            print("\(player.name) healed.")
        case "activateLightHammer":
            player.activateLightHammer()
        default:
            break
        }

        print("Monster's turn:")
        print(monster.attack(target: player))

        player.updateBuffs()
        monster.updateBuffs()
    }

    // Выводим результат
    if player.isAlive() {
        print("Player wins!")
    } else {
        print("Monster wins!")
    }
}

main()
