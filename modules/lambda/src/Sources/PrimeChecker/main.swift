import AWSLambdaRuntime
import Foundation

struct PrimeRequest: Codable {
    let number: Int
}

struct PrimeResponse: Codable {
    let number: Int
    let isPrime: Bool
    let message: String
}

struct ErrorResponse: Codable {
    let error: String
}

func isPrime(_ n: Int) -> Bool {
    if n < 2 {
        return false
    }
    if n == 2 {
        return true
    }
    if n % 2 == 0 {
        return false
    }
    
    let limit = Int(sqrt(Double(n)))
    for i in stride(from: 3, through: limit, by: 2) {
        if n % i == 0 {
            return false
        }
    }
    return true
}

@main
struct PrimeChecker: SimpleLambdaHandler {
    func handle(_ event: PrimeRequest, context: LambdaContext) async throws -> PrimeResponse {
        let number = event.number
        let prime = isPrime(number)
        
        let message = prime ? 
            "\(number) is a prime number" : 
            "\(number) is not a prime number"
        
        return PrimeResponse(
            number: number,
            isPrime: prime,
            message: message
        )
    }
}