contract;

use std::{
    bytes::Bytes,
    convert::From,
    string::String,
    block::timestamp,
    storage::storage_map::*,
    bytes_conversions::{u16::*, u64::*},
    primitive_conversions::{ u64::*, b256::* },
    intrinsics::{size_of, size_of_val},
    hash::*,
    storage::storage_bytes::*,
    storage::storage_string::*,
};



enum BytesValue {
    Bool: bool,
    B256: b256,
    U64: u64, 
    U16: u16,
    String: String,
}

abi ValidityContract {
    fn test_read_bytes() -> (b256,  b256,  bool,  u64,  u16);
    fn test_verify_grace_period() -> bool;
    fn test_verify_grace_period_expired() -> bool;
    
    #[storage(read, write)]
    fn register_domain(domain_name: String);
}

impl BytesValue {
    fn as_bool(self) -> bool {
        match self {
            Self::Bool(value) => value,
            _ => revert(0),
        }
    }

    fn as_b256(self) -> b256 {
        match self {
            Self::B256(value) => value,
            _ => revert(0),
        }
    }

    fn as_string(self) -> String {
        match self {
            Self::String(value) => value,
            _ => revert(0),
        }
    }

    fn as_u64(self) -> u64 {
        match self {
            Self::U64(value) => value,
            _ => revert(0),
        }
    }

    fn as_u16(self) -> u16 {
        match self {
            Self::U16(value) => value,
            _ => revert(0),
        }
    }

  
    
}

pub struct BakoHandle {
    name: String,
    owner: b256,
    resolver: b256,
    primary: bool,
    timestamp: u64,
    period: u16,
}


fn read_bytes(bytes: Bytes) -> (Bytes, BytesValue) {
    let (left, right) = bytes.split_at(3);
    let value_len = left.get(1).unwrap();
    let value_type = left.get(2).unwrap();
    let (value_bytes, right) = right.split_at(value_len.as_u64());
    let value = match value_type {
        1 => BytesValue::String(String::from(value_bytes)),
        2 => BytesValue::B256(b256::try_from(value_bytes).unwrap()),
        3 => BytesValue::Bool(value_bytes.get(0).unwrap() == 1u8),
        4 => BytesValue::U64(u64::from_be_bytes(value_bytes)),
        5 => BytesValue::U16(u16::from_be_bytes(value_bytes)),
        _ => revert(0),
    };
    return (right, value);
}

fn verify_grace_period(handle: BakoHandle) -> bool {
    let current_timestamp = timestamp();   

    let handle_timestamp: u64 = handle.timestamp;
    let handle_period: u16 = handle.period;

    let grace_period_90days: u64 = 90 * 24 * 3600;  // 90 days * 24 hours/day * 3600 seconds/hour = 7776000 seconds
    let grace_period = handle_timestamp + handle_period.as_u64() + grace_period_90days;

    log(current_timestamp);
    log(handle_timestamp);
    log(grace_period);

    return grace_period > current_timestamp;
}

fn msgsender_address() -> Address {
    match std::auth::msg_sender().unwrap() {
        Identity::Address(identity) => identity,
        _ => revert(0),
    }
}

impl From<Bytes> for BakoHandle {
    fn from(bytes: Bytes) -> Self {
        // Get the name length and name bytes
        let (bytes, value) = read_bytes(bytes);
        let name = value.as_string();
        
        // Get the owner address length and address bytes
        let (bytes, value) = read_bytes(bytes);
        let owner = value.as_b256();

        // Get the resolver address length and address bytes
        let (bytes, value) = read_bytes(bytes);
        let resolver = value.as_b256();

        // Get the resolver address length and address bytes
        let (bytes, value) = read_bytes(bytes);
        let primary = value.as_bool();

        let (bytes, value) = read_bytes(bytes);
        let timestamp = value.as_u64();

        let (_, value) = read_bytes(bytes);
        let period = value.as_u16();
      
        return Self {
            name,
            owner,
            resolver,
            primary,
            timestamp,
            period,
        };
    }

    fn into(self) -> Bytes {
        let mut bytes = Bytes::new();

        // Append the name length and name bytes
        bytes.append(self.name.as_bytes().len().try_as_u16().unwrap().to_be_bytes());
        bytes.push(1u8);
        bytes.append(self.name.as_bytes());

        // Append the owner address length and address bytes
        bytes.append(Bytes::from(self.owner).len().try_as_u16().unwrap().to_be_bytes());
        bytes.push(2u8);
        bytes.append(Bytes::from(self.owner));

        // Append the resolver address length and address bytes
        bytes.append(Bytes::from(self.resolver).len().try_as_u16().unwrap().to_be_bytes());
        bytes.push(2u8);
        bytes.append(Bytes::from(self.resolver));
        
        // Append bytes representing the primary field
        bytes.push(0u8);
        bytes.push(1u8);
        bytes.push(3u8);
        bytes.push(match self.primary { true => 1u8, false => 0u8, });

        
        let mut timestamp_bytes = Bytes::new();
        let timestamp_number = self.timestamp;
        timestamp_bytes.append(timestamp_number.to_be_bytes());

        bytes.append(timestamp_bytes.len().try_as_u16().unwrap().to_be_bytes());
        bytes.push(4u8);
        bytes.append(timestamp_bytes);

        // Append bytes representing the period field
        let period_bytes = self.period.to_be_bytes();
        bytes.append(period_bytes.len().try_as_u16().unwrap().to_be_bytes());
        bytes.push(5u8);
        bytes.append(period_bytes);

        return bytes;
    }
} 

impl BakoHandle {
    pub fn new(name: String, owner: b256, resolver: b256,  primary: bool, timestamp: u64, period: u16) -> Self {
        Self {
            name,
            owner,
            resolver,
            primary,
            timestamp,
            period,
        }
    }

    pub fn is_expired(self) -> bool {
        let current_timestamp = timestamp();   
        let year_in_seconds: u64 = 365 * 24 * 3600;  // 365 days * 24 hours/day * 3600 seconds/hour = 31.536.000 seconds
        let grace_period_90days: u64 = 90 * 24 * 3600;  // 90 days * 24 hours/day * 3600 seconds/hour = 7.776.000 seconds

        let handle_timestamp: u64 = self.timestamp;
        let handle_period: u16 = self.period;

        let grace_period = handle_timestamp + (handle_period.as_u64() * year_in_seconds) + grace_period_90days;

        log(current_timestamp);
        log(handle_timestamp);
        log(grace_period);

        // Check if the current timestamp is greater than the grace period, if so, the domain is expired
        return grace_period > current_timestamp;
    } 
}

storage {
  domains: StorageMap<b256, StorageBytes> = StorageMap {}
}


enum ValidyContractError {
    DomainUnavailable: (),
}

impl ValidityContract for Contract {
    
    #[storage(read, write)]
    fn register_domain(domain_name: String) {
        let address = msgsender_address();
        let handle = sha256(domain_name);
        let current_timestamp = timestamp();
        
        let domain = storage.domains.get(handle).read_slice();

        if domain.is_some(){
            let handle = BakoHandle::from(domain.unwrap());
            require(!handle.is_expired(), ValidyContractError::DomainUnavailable); // If expired it is unavailable
        }

        let retrived_domain = BakoHandle::new(
            domain_name,
            sha256(address),
            sha256(address),
            true,
            current_timestamp, 
            1,
        );

        storage.domains.insert(handle, StorageBytes {});
        storage.domains.get(handle).write_slice(retrived_domain.into());
    }

    fn test_read_bytes() -> (b256, b256, bool, u64, u16) {
        use std::hash::*;

        let my_handle = BakoHandle::new(
            String::from_ascii_str("myhandle"),
            sha256("OWNER"),
            sha256("RESOLVER"),
            true,
            timestamp(),
            1,
        );

        let bytes: Bytes = my_handle.into();

        let (bytes, value) = read_bytes(bytes);
        let name = value.as_string();
        assert(name == my_handle.name);

        let (bytes, value) = read_bytes(bytes);
        let owner = value.as_b256();
        assert(owner == my_handle.owner);

        let (bytes, value) = read_bytes(bytes);
        let resolver = value.as_b256();
        assert(resolver == my_handle.resolver);

        let (bytes, value) = read_bytes(bytes);
        let is_primary = value.as_bool();
        assert(is_primary == my_handle.primary);

        let (bytes, value) = read_bytes(bytes);
        let timestamp = value.as_u64();
        assert(timestamp == my_handle.timestamp);

        let (_, value) = read_bytes(bytes);
        let period = value.as_u16();
        assert(period == my_handle.period);

        return (owner, resolver, is_primary, timestamp, period);
    }

    fn test_verify_grace_period() -> bool {
        use std::hash::*;
        let handle = BakoHandle::new(
            String::from_ascii_str("myhandle"),
            sha256("OWNER"),
            sha256("RESOLVER"),
            true,
            timestamp(),
            1,
        );

        return verify_grace_period(handle);
    }

    fn test_verify_grace_period_expired() -> bool {
        use std::hash::*;
        let handle = BakoHandle::new(
            String::from_ascii_str("myhandle"),
            sha256("OWNER"),
            sha256("RESOLVER"),
            true,
            timestamp() - 91 * 24 * 3600,
            1,
        );

        return verify_grace_period(handle);
    }

}



#[test] 
fn test_read_bytes() {
    use std::hash::*;

    let my_handle = BakoHandle::new(
        String::from_ascii_str("myhandle"),
        sha256("OWNER"),
        sha256("RESOLVER"),
        true,
        timestamp(),
        1,
    );

    let bytes: Bytes = my_handle.into();

    let (bytes, value) = read_bytes(bytes);
    let name = value.as_string();
    assert(name == my_handle.name);

    let (bytes, value) = read_bytes(bytes);
    let owner = value.as_b256();
    assert(owner == my_handle.owner);

    let (bytes, value) = read_bytes(bytes);
    let resolver = value.as_b256();
    assert(resolver == my_handle.resolver);

    let (bytes, value) = read_bytes(bytes);
    let is_primary = value.as_bool();
    assert(is_primary == my_handle.primary);

    let (bytes, value) = read_bytes(bytes);
    let timestamp = value.as_u64();
    assert(timestamp == my_handle.timestamp);

    let (_, value) = read_bytes(bytes);
    let period = value.as_u16();
    assert(period == my_handle.period);
}

#[test(should_revert)] 
fn test_read_invalid_byte_value() {
    use std::hash::*;

    let my_handle = BakoHandle::new(
        String::from_ascii_str("myhandle"),
        sha256("OWNER"),
        sha256("RESOLVER"),
        true,
        timestamp(),
        1,
    );
    let bytes: Bytes = my_handle.into();

    let (bytes, value) = read_bytes(bytes);
    let name = value.as_b256();
}

#[test]
fn test_verify_grace_period() {
    use std::hash::*;
    let handle = BakoHandle::new(
        String::from_ascii_str("myhandle"),
        sha256("OWNER"),
        sha256("RESOLVER"),
        true,
        timestamp(),
        1,
    );

    assert(verify_grace_period(handle) == true);
}

#[test]
fn test_verify_grace_period_expired() {
    use std::hash::*;
    let handle = BakoHandle::new(
        String::from_ascii_str("myhandle"),
        sha256("OWNER"),
        sha256("RESOLVER"),
        true,
        timestamp() - 90 * 24 * 3601,
        1,
    );

    assert(verify_grace_period(handle) == false);
}

#[test]
fn test_register_domain() {
    use std::constants::*;

    let test = abi(ValidityContract, ZERO_B256);

    let _ = test.register_domain(String::from_ascii_str("mydomain"));
}
