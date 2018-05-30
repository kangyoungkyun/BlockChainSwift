
import Cocoa

//거래가 발생할때 거래 타입 선택 가능
enum TransactionType : String, Codable{
    case domestic
    case international
}

// 스마트 컨트랙드 프로토콜 함수 - 지원,신청하는 계약임
protocol SmartContract{
    func apply(transaction : Transaction)
}

//스마트 컨트랙트를 상속한 함수 구현
class TransactionTypeSmartContract : SmartContract{
    //스마트 컨트랙트 함수가 호출되면 apply 함수 실행
    func apply(transaction: Transaction) {
        
        var fees = 0.0
        //거래 타입에 따라 fees 계산해주기
        switch transaction.transactionType {
        case .domestic:
            fees = 0.02
        case .international:
            fees = 0.05
        }
        //거래 타입에 따라서 항목 계산 후 대입
        transaction.fees = transaction.amount * fees
        transaction.amount -= transaction.fees
    }
}



//거래 데이터 구조체
class Transaction : Codable{
    var from: String
    var to: String
    var amount: Double
    
    //수수료
    var fees: Double = 0.0
    //거래 타입
    var transactionType : TransactionType
    
    //초기화
    init(from:String,to:String,amount:Double,transactionType:TransactionType) {
        self.from = from
        self.to = to
        self.amount = amount
        self.transactionType = transactionType
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
    
    //스마트 계약 관련 데이터 배열 변수
    private (set) var smartContracts : [SmartContract] = [TransactionTypeSmartContract()]
    
    
    //초기화
    init(genesisBlock : Block){
        addBlock(genesisBlock)
    }
    
    private enum CodingKeys : CodingKey {
        case blocks
    }
    

    //블록체인 구조체에 블록을 추가하는 함수
    func addBlock(_ block : Block){
        //체인에 아무런 블록이 없으면 제네시스 블록 생성
        if self.blocks.isEmpty{
            //제네시스 블록의 이전 해쉬값 (임의지정)
            block.previousHash = "0000000000"
            //제네시스 블록의 해쉬값
            block.hash = generateHash(for :block)
        }
        
        // run the smart contracts
        self.smartContracts.forEach { contract in
            block.transactions.forEach { transaction in
                contract.apply(transaction: transaction)
            }
        }
        
        //삽입
        self.blocks.append(block)
    }
    
    //해쉬 생성 함수
    func generateHash(for block : Block) -> String{
        //block의 key 값을 이용해서 hash 값을 만들어 낸다.
        var hash = block.key.sha1Hash()
        // 특정값 (앞 2자리가 00 인 hash 값 구하기
        while(!hash.hasPrefix("00")){
            //조건이 맞지 않을 경우 block의 noce 값 증가
            block.nonce += 1
            hash = block.key.sha1Hash()
            print(hash)
        }
        
        return hash
    }
    
    //새로운 블락 구하는 함수, 다음 블록 생성
    func getNextBlock(transactions:[Transaction]) ->Block{
        //새 블록 객체
        let block = Block()
        //새로운 블록이 생성될때는 이전 거래 내역이 배열로 들어간다.
        transactions.forEach { (transaction) in
            block.addTransaction(transaction: transaction)
        }
        //새로운 블록에는 이전 블록의 hash 값, 번호, 자신의 hash 값이 들어간다.
        let previousBlock = getPreviousBlock()
        block.index = self.blocks.count
        block.previousHash = previousBlock.hash
        block.hash = generateHash(for: block)
        return block
    }
    
    //이전 블럭 가져오기
    private func getPreviousBlock() -> Block {
        return self.blocks[self.blocks.count - 1]
    }
}

//제네시스 블록 생성
let genesisBlock = Block()
//추가
let blockchain = Blockchain(genesisBlock: genesisBlock)

//새로운 거래 발생
let transaction = Transaction(from: "kim", to: "hong", amount: 1000,transactionType:.international)

print("--------------------------------------------------------")
//위에서 발생한 거래내역을 새로운 블럭을 생성하는 함수안에 넣어주었다.
let block = blockchain.getNextBlock(transactions: [transaction])
//새로만든 블록을 넣어주고
blockchain.addBlock(block)


//인코딩
let data = try! JSONEncoder().encode(blockchain)
//json데이터를 string으로 출력
let blockchainJSON = String(data: data, encoding: .utf8)

print(blockchainJSON!)

//블록의 총 개수를 확인해보자.
//print(blockchain.blocks.count)


//let block1 = Block()
//block1.addTransaction(transaction: transaction)
//block1.key


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







