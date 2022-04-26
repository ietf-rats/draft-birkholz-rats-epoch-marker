---
v: 3

title: Epoch Markers
abbrev: Epoch Markers
docname: draft-birkholz-rats-epoch-markers-latest
stand_alone: true
area: Security
wg: RATS Working Group
kw: Internet-Draft

cat: std
consensus: true
submissiontype: IETF

author:
- name: Henk Birkholz
  org: Fraunhofer SIT
  abbrev: Fraunhofer SIT
  email: henk.birkholz@sit.fraunhofer.de
  street: Rheinstrasse 75
  code: '64295'
  city: Darmstadt
  country: Germany
- name: Thomas Fossati
  organization: Arm Limited
  email: Thomas.Fossati@arm.com
  country: UK
- name: Wei Pan
  org: Huawei Technologies
  email: william.panwei@huawei.com
- name: Carsten Bormann
  org: Universität Bremen TZI
  street: Bibliothekstr. 1
  city: Bremen
  code: D-28359
  country: Germany
  phone: +49-421-218-63921
  email: cabo@tzi.org

normative:
  RFC3161:
  
informative:
  I-D.ietf-rats-architecture: rats-arch

venue:
  mail: rats@ietf.org
  github: ietf-rats/draft-birkholz-rats-epoch-marker

--- abstract

Abstract Text

--- middle

# Introduction

Systems that are required to interact via secure interactions often require a shared understanding of the freshness of conveyed information, especially in the domain of remote attestation procedures.
Establishing a notion of freshness between various involved entities taking on roles that rely on information that is not outdated is not simple.
In general, establishing a shared understanding of freshness in a secure manner is not simple.
The RATS architecture {{-rats-arch}} dedicates an extensive appendix solely on the topic of freshness considerations and that fact alone should be considered a telltale sign on how necessary yet complex establishing a trusted and shared understanding of freshness between systems actually is.

This document provides a prominent way to establish a notion of freshness between systems: Epoch Markers.
Epoch Markers are messages that are like time ticks produced and conveyed by a system in a freshness domain: the Epoch Bell.
Systems that receive Epoch Markers do not have to track freshness with their own local understanding of time (e.g., a local real time clock).
Instead, each reception of a specific Epoch Marker rings in a new age of freshness that is shared between all recipients.
In essence, the emissions and corresponding receptions of Epoch Markers are like the ticks of a clock where the ticks are conveyed by the Internet.

The layout of the freshness domain in which Epoch Markers are conveyed like the ticks of a clock, introduces a domain-specific latency -- and therefore a certain uncertainty about tick accuracy.

While all Epoch Markers share the common characteristic of being like clock ticks in a freshness domain, there are various payload types that can make up the content of an Epoch Marker.
These different types of Epoch Marker payloads address several specific use cases and are laid out in this document.
While Epoch Markers are encoded in CBOR and many of the payload types are encoded in CBOR as well, a prominent payload is the Time Stamp Token content as defined by {{RFC3161}}: a DER-encoded TSTInfo value.
Time Stamp Tokens (TST) produced by Time Stamp Authorities (TSA) are conveyed by the Time Stamp Protocol (TSP).
At the time of writing,
TSAs are the most common world-wide implemented secure timestamp token systems.
Reusing the essential TST payload structure as a payload type for CBOR encoded Epoch Markers makes sense with respect to migration paths and general interoperability.
But there is more than one way to represent a signed timestamp and other kinds of freshness ticks that can be used for Epoch Markers.

In this document, basic interaction models on how to convey Epoch Marchers are illustrated as they impact the message design of a generic Epoch Marker.
Then, the structure of Epoch Markers is specified using CDDL and the corresponding payload types are introduced and elaborated on.
To increase the level of trustworthiness in the Epoch Bell and the
system that produces them,
Epoch Markers also provide the option to include (concise) remote attestation evidence or corresponding remote attestation results.

## Requirements Notation

{::boilerplate bcp14-tagged}

# Epoch IDs

The RATS architecture introduces the concept of Epoch IDs that mark certain events during remote attestation procedures ranging from simple handshakes to rather complex interactions including elaborate freshness proofs.
Epoch Markers are a solution that includes the lessons learned from TSAs and provides several means to identify a new freshness epoch as illustrated by the RATS architecture.

# Interaction Models

The interaction models illustrated in this section are derived from the RATS Reference Interaction Models.
In general there are three of them:

* unsolicited distribution (e.g., via uni-directional methods, such as broad- or multicasting from Epoch Bells)
* solicited distribution (e.g., via a subscription to Epoch Bells)
* ad-hoc requests (e.g., via challenge-response requests addressed at Epoch Bells)

# Epoch Marker CDDL

~~~~ CDDL
epoch-marker = [
  header,
  $payload,
]

header = {
  ? challenge-response-nonce,
  ? remote-attestation-evidence, ; could be EAT or Concise Evidence
  ? remote-attestation-results, ; hopefully EAT with AR4SI Claims
}

challenge-response-nonce = (1: "PLEASE DEFINE")
remote-attestation-evidence = (2: "PLEASE DEFINE")
remote-attestation-results = (3: "PLEASE DEFINE")

;payload types independent on interaction model
$payload /= native-rfc3161-TST-info
$payload /= TST-info-based-on-CBOR-time-tag
$payload /= CBOR-time-tag
$payload /= multi-nonce
$payload /= multi-nonce-list
$payload /= strictly-monotonically-increasing-counter

native-rfc3161-TST-info = bytes ;  DER-encoded value of TSTInfo

TST-info-based-on-CBOR-time-tag = "PLEASE DEFINE"

; ~~~
; ~~~ verbatim translation of ASN.1 TSTInfo into CDDL
; ~~~ (GeneralName is TODO atm, due to its terrible callousness)
; ~~~

TSTInfo = {
  &(version : 0) => int .default 1
  &(policy : 1) => oid
  &(messageImprint : 2) => MessageImprint
  &(serialNumber : 3) => int
  &(genTime : 4) => GeneralizedTime
  ? &(accuracy : 5) => Accuracy
  &(ordering : 6) => bool .default false
  ? &(nonce : 7) => int
  ? &(tsa : 8) => GeneralName
  * $$TSTInfoExtensions
}

MessageImprint = [
  hashAlgorithm: AlgorithmIdentifier
  hashedMessage: bytes
]

AlgorithmIdentifier = [
  algorithm:  oid
  ? parameters: any
]

Accuracy = non-empty<{
  ? &(seconds : 0) => int
  ? &(millis: 1) => 1..999
  ? &(micros: 2) => 1..999
}>

; https://datatracker.ietf.org/doc/html/rfc5280#section-4.1.2.5.2
GeneralizedTime = tstr .regexp '[0-9]{14}(\.[0-9]+)?Z'

GeneralName = "todo"

; stuff
oid = #6.111(bstr)
non-empty<M> = (M) .and ({ + any => any })

CBOR-time-tag = [
time-tag,
? nonce
]

time-tag = "PLEASE DEFINE"
nonce = "PLEASE DEFINE"

multi-nonce = tstr / bstr / int

multi-nonce-list = [+ multi-nonce]

strictly-monotonically-increasing-counter = uint ; counter context? per issuer? per indicator?
~~~~

## RFC 3161 TSTInfo

~~~~ DER
TSTInfo ::= SEQUENCE  {
   version                      INTEGER  { v1(1) },
   policy                       TSAPolicyId,
   messageImprint               MessageImprint,
     -- MUST have the same value as the similar field in
     -- TimeStampReq
   serialNumber                 INTEGER,
    -- Time-Stamping users MUST be ready to accommodate integers
    -- up to 160 bits.
   genTime                      GeneralizedTime,
   accuracy                     Accuracy                 OPTIONAL,
   ordering                     BOOLEAN             DEFAULT FALSE,
   nonce                        INTEGER                  OPTIONAL,
     -- MUST be present if the similar field was present
     -- in TimeStampReq.  In that case it MUST have the same value.
   tsa                          [0] GeneralName          OPTIONAL,
   extensions                   [1] IMPLICIT Extensions   OPTIONAL  }
~~~~

--- back

# Acknowledgements
{:unnumbered}

TBD
