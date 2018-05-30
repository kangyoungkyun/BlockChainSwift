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
    
    //key 변수
    var key : String {
        get{
            //위 transaction 배열을 json 형식으로 변경
            let transactionsData = try! JSONEncoder().encode(self.transactions)
            // json형식의 transaction 배열을 String 값으로 변경
            let transactionsJSONString = String(data: transactionsData, encoding:.utf8)
            //번호, 이전해쉬, nonce + transactionString 값을 이용해서 고유 key 생성
            return String(self.index) + self.previousHash + String(self.nonce) + transactionsJSONString!
        }
    }
    //거래 내역을 담는 함수
    func addTransaction(transaction: Transaction){
        self.transactions.append(transaction)
    }

    //초기화
    init(){
        self.nonce = 0
    }
}

//체인 구조체
class Blockchain : Codable {
    //블록이 배열형태로 저장됨
    private (set) var blocks : [Block] = [Block]()
    
    //초기화
    init(genesisBlock : Block){
        addBlock(genesisBlock)
    }
    
    //블록체인 구조체에 블록을 추가하는 함수
    private func addBlock(_ block : Block){
        //체인에 아무런 블록이 없으면 제네시스 블록 생성
        if self.blocks.isEmpty{
            //제네시스 블록의 이전 해쉬값 (임의지정)
            block.previousHash = "0000000000"
            //제네시스 블록의 해쉬값
            block.hash = generateHash(for :block)
        }
        //삽입
        self.blocks.append(block)
    }
    
    //해쉬 생성 함수
    func generateHash(for block : Block) -> String{
        //block의 key 값을 이용해서 hash 값을 만들어 낸다.
        let hash = block.key.sha1Hash()
        return hash
    }
}

//제네시스 블록 생성
let genesisBlock = Block()
//추가
let blockchain = Blockchain(genesisBlock: genesisBlock)


let transaction = Transaction(from: "kim", to: "hong", amount: 1000)
let block1 = Block()
block1.addTransaction(transaction: transaction)
block1.key






// String 확장
extension String {
    
    func sha1Hash() -> String {
        
        let task = Process()
        task.launchPath = "/usr/bin/shasum"
        task.arguments = []
        
        let inputPipe = Pipe()
        
        inputPipe.fileHandleForWriting.write(self.data(using: String.Encoding.utf8)!)
        
        inputPipe.fileHandleForWriting.closeFile()
        
        let outputPipe = Pipe()
        task.standardOutput = outputPipe
        task.standardInput = inputPipe
        task.launch()
        
        let data = outputPipe.fileHandleForReading.readDataToEndOfFile()
        let hash = String(data: data, encoding: String.Encoding.utf8)!
        return hash.replacingOccurrences(of: "  -\n", with: "")
    }
}







