// project.move
module DecentralizedCertificateVerificationPlatform ::certificate_verification {
    use std::signer;
    use std::string;
    use aptos_framework::timestamp;

    const E_CERTIFICATE_EXISTS: u64 = 1;
    const E_CERTIFICATE_NOT_FOUND: u64 = 2;
    const E_NOT_AUTHORIZED: u64 = 3;

    struct Certificate has key, store {
        issuer: address,
        holder: address,
        certificate_id: string::String,
        issue_date: u64,
        is_valid: bool
    }

    public entry fun issue_certificate(
        issuer: &signer,
        holder: address,
        certificate_id: string::String
    ) {
        let issuer_address = signer::address_of(issuer);
        
        let certificate = Certificate {
            issuer: issuer_address,
            holder,
            certificate_id,
            issue_date: timestamp::now_seconds(),
            is_valid: true
        };
        
        move_to(issuer, certificate);
    }

    public entry fun verify_revoke_certificate(
        authority: &signer,
        holder: address
    ): bool acquires Certificate {
        let auth_address = signer::address_of(authority);
        let certificate = borrow_global_mut<Certificate>(holder);
        assert!(certificate.issuer == auth_address, E_NOT_AUTHORIZED);
        let is_valid = certificate.is_valid;
        certificate.is_valid = false;
        is_valid
    }
}