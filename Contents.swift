//: Playground - noun: a place where people can play

/*
 
 
 
 */



import Cocoa

//거래 데이터 구조체
class Transaction : Codable{
    var from: String
    var to: String
    var amount: Double
    //초기화
    init(from:String,to:String,amount:Double) {
        self.from = from
        self.to = to
        self.amount = amount
    }
    
}

//블록 구조체
class Block: Codable{
    //번호, 이전해쉬,해쉬,nonce를 가지고 있다.
    var index : Int = 0
    var previousHash : String = ""
    var hash: String!
    var nonce : Int

    //거래 내역을 가지고 있다.
    private (set) var transactions : [Transaction] = [Transaction]()
    
    var key : String {
        get{
            let transactionsData = try! JSONEncoder().encode(self.transactions)
            let transactionsJSONString = String(data: transactionsData, encoding:.utf8)
            return String(self.index) + self.previousHash + String(self.nonce) + transactionsJSONString!
        }
    }

    func addTransaction(transaction: Transaction){
        self.transactions.append(transaction)
    }

    //초기화
    init(){
        self.nonce = 0
    }
}

//체인 구조체
class BlockChain : Codable {
    //블록이 배열형태로 저장됨
    private (set) var blocks : [Block] = [Block]()
}


let transaction = Transaction(from: "kim", to: "hong", amount: 1000)

let block1 = Block()
block1.key














