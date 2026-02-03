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

// Lambda handler using the 0.5.2 API with string-based handler
Lambda.run { (context: Lambda.Context, event: String, callback: @escaping (Result<String, Error>) -> Void) in
    
    let corsHeaders = """
    {
        "Content-Type": "application/json",
        "Access-Control-Allow-Origin": "*",
        "Access-Control-Allow-Headers": "Content-Type",
        "Access-Control-Allow-Methods": "POST, OPTIONS"
    }
    """
    
    // Try to parse the event as JSON
    guard let eventData = event.data(using: .utf8),
          let eventJson = try? JSONSerialization.jsonObject(with: eventData) as? [String: Any] else {
        let errorResponse = """
        {
            "statusCode": 400,
            "headers": \(corsHeaders),
            "body": "{\\"error\\": \\"Invalid request format\\"}"
        }
        """
        callback(.success(errorResponse))
        return
    }
    
    // Handle OPTIONS request for CORS
    if let httpMethod = eventJson["httpMethod"] as? String, httpMethod == "OPTIONS" {
        let response = """
        {
            "statusCode": 200,
            "headers": \(corsHeaders),
            "body": ""
        }
        """
        callback(.success(response))
        return
    }
    
    // Get the body from the event
    guard let bodyString = eventJson["body"] as? String,
          let bodyData = bodyString.data(using: .utf8) else {
        let errorResponse = """
        {
            "statusCode": 400,
            "headers": \(corsHeaders),
            "body": "{\\"error\\": \\"Invalid request body\\"}"
        }
        """
        callback(.success(errorResponse))
        return
    }
    
    do {
        let primeRequest = try JSONDecoder().decode(PrimeRequest.self, from: bodyData)
        let number = primeRequest.number
        let prime = isPrime(number)
        
        let message = prime ? 
            "\(number) is a prime number" : 
            "\(number) is not a prime number"
        
        let primeResponse = PrimeResponse(
            number: number,
            isPrime: prime,
            message: message
        )
        
        let responseData = try JSONEncoder().encode(primeResponse)
        let responseBody = String(data: responseData, encoding: .utf8) ?? "{\"error\": \"Encoding error\"}"
        
        let response = """
        {
            "statusCode": 200,
            "headers": \(corsHeaders),
            "body": "\(responseBody.replacingOccurrences(of: "\"", with: "\\\""))"
        }
        """
        callback(.success(response))
        
    } catch {
        let errorResponse = """
        {
            "statusCode": 400,
            "headers": \(corsHeaders),
            "body": "{\\"error\\": \\"Invalid input. Please provide a valid number.\\"}"
        }
        """
        callback(.success(errorResponse))
    }
}