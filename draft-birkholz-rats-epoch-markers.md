---
v: 3

title: Epoch Markers
abbrev: Epoch Markers
docname: draft-birkholz-rats-epoch-markers-latest
stand_alone: true
area: Security
wg: RATS Working Group
kw: Internet-Draft

venue:
  email: rats@ietf.org
  github: https://github.com/ietf-rats/draft-birkholz-rats-epoch-marker

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
  RFC3161: TSA
  RFC5652: CMS
  RFC8610: CDDL
  RFC2104: HMAC
  RFC9090: CBOR-OID
  RFC9054: COSE-HASH-ALGS
  STD94:
    -: CBOR
    =: RFC8949
  STD96:
    -: COSE
    =: RFC9052
  I-D.ietf-cbor-time-tag: CBOR-ETIME
  I-D.ietf-cose-cbor-encoded-cert: C509
  X.690:
    title: >
      Information technology — ASN.1 encoding rules:
      Specification of Basic Encoding Rules (BER), Canonical Encoding
      Rules (CER) and Distinguished Encoding Rules (DER)
    author:
      org: International Telecommunications Union
    date: 2015-08
    seriesinfo:
      ITU-T: Recommendation X.690
    target: https://www.itu.int/rec/T-REC-X.690

informative:
  I-D.ietf-rats-architecture: rats-arch
  I-D.ietf-rats-reference-interaction-models: rats-models
  I-D.birkholz-scitt-receipts: scitt-receipts

venue:
  mail: rats@ietf.org
  github: ietf-rats/draft-birkholz-rats-epoch-marker

entity:
  SELF: "RFCthis"

--- abstract

This document defines Epoch Markers as a way to establish a notion of freshness among actors in a distributed system. Epoch Markers are similar to "time ticks" and are produced and distributed by a dedicated system, the Epoch Bell. Systems that receive Epoch Markers do not have to track freshness using their own understanding of time (e.g., via a local real-time clock). Instead, the reception of a certain Epoch Marker establishes a new epoch that is shared between all recipients.

--- middle

# Introduction

Systems that need to interact securely often require a shared understanding of the freshness of conveyed information.
This is certainly the case in the domain of remote attestation procedures.
In general, securely establishing a shared notion of freshness of the exchanged information among entities in a distributed system is not a simple task.

The entire {{Appendix A of -rats-arch}} deals solely with the topic of freshness, which is in itself an indication of how relevant, and complex, it is to establish a trusted and shared understanding of freshness in a RATS system.


This document defines Epoch Markers as a way to establish a notion of freshness among actors in a distributed system.
Epoch Markers are similar to "time ticks" and are produced and distributed by a dedicated system, the Epoch Bell.
Systems that receive Epoch Markers do not have to track freshness using their own understanding of time (e.g., via a local real-time clock).
Instead, the reception of a certain Epoch Marker establishes a new epoch that is shared between all recipients.
In essence, the emissions and corresponding receptions of Epoch Markers are like the ticks of a clock where the ticks are conveyed by the Internet.

In general (barring highly symmetrical topologies), epoch ticking incurs differential latency due to the non-uniform distribution of receivers with respect to the Epoch Bell.  This introduces skew that needs to be taken into consideration when Epoch Markers are used.

While all Epoch Markers share the same core property of behaving like clock ticks in a shared domain, various "epoch id" types are defined to accommodate different use cases and diverse kinds of Epoch Bells.

While Epoch Markers are encoded in CBOR {{-CBOR}}, and many of the epoch id types are themselves encoded in CBOR, a prominent format in this space is the Time-Stamp Token defined by {{-TSA}}, a DER-encoded TSTInfo value wrapped in a CMS envelope {{-CMS}}.
Time-Stamp Tokens (TST) are produced by Time-Stamp Authorities (TSA) and exchanged via the Time-Stamp Protocol (TSP).
At the time of writing, TSAs are the most common providers of secure time-stamping services.
Therefore, reusing the core TSTInfo structure as an epoch id type for Epoch Markers is instrumental for enabling smooth migration paths and promote interoperability.
There are, however, several other ways to represent a signed timestamp, and therefore other kinds of payloads that can be used to implement Epoch Markers.

To inform the design, this document discusses a number of interaction models in which Epoch Markers are expected to be exchanged.
The top-level structure of Epoch Markers and an initial set of epoch id types are specified using CDDL {{-CDDL}}.
To increase trustworthiness in the Epoch Bell, Epoch Markers also provide the option to include a "veracity proof" in the form of attestation evidence, attestation results, or SCITT receipts {{-scitt-receipts}} associated with the trust status of the Epoch Bell.

## Requirements Notation

{::boilerplate bcp14-tagged}

In this document, CDDL {{-CDDL}} is used to describe the data formats.  The examples in {{examples}} use CBOR diagnostic notation as defined in {{Section 8 of -CBOR}} and {{Appendix G of -CDDL}}.

# Epoch IDs

The RATS architecture introduces the concept of Epoch IDs that mark certain events during remote attestation procedures ranging from simple handshakes to rather complex interactions including elaborate freshness proofs.
The Epoch Markers defined in this document are a solution that includes the lessons learned from TSAs, the concept of Epoch IDs defined in the RATS architecture, and provides several means to identify a new freshness epoch. Some of these methods are introduced and discussed in Section 10.3 of the RATS architecture {{-rats-arch}}.

# Interaction Models {#interaction-models}

The interaction models illustrated in this section are derived from the RATS Reference Interaction Models.
In general, there are three interaction models:

* ad-hoc requests (e.g., via challenge-response requests addressed at Epoch Bells), corresponding to Section 7.1 in {{-rats-models}}
* unsolicited distribution (e.g., via uni-directional methods, such as broad- or multicasting from Epoch Bells), corresponding to Section 7.2 in {{-rats-models}}
* solicited distribution (e.g., via a subscription to Epoch Bells), corresponding to Section 7.3 in {{-rats-models}}

# Epoch Marker Structure

At the top level, an Epoch Marker is a CBOR array with a header carrying an optional veracity proof about the Epoch Bell and a payload.

~~~~ CDDL
{::include cddl/epoch-marker.cddl}
~~~~
{: #fig-epoch-marker-cddl artwork-align="left"
   title="Epoch Marker definition"}

## Epoch Marker Payloads

This memo comes with a set of predefined payloads.

### CBOR Time Tag (etime)

CBOR extended time tag (1001) optionally bundled with a nonce.

See {{Section 3 of -CBOR-ETIME}} for the (many) details about the CBOR extended
time format.

~~~~ CDDL
{::include cddl/cbor-time-tag.cddl}
~~~~

### Classical RFC 3161 TST Info {#sec-rfc3161-classic}

DER-encoded {{X.690}} TSTInfo {{-TSA}}.  See {{classic-tstinfo}} for the layout.

~~~~ CDDL
{::include cddl/classical-rfc3161-tst-info.cddl}
~~~~

### CBOR-encoded RFC3161 TST Info {#sec-rfc3161-fancy}

[^issue] https://github.com/ietf-rats/draft-birkholz-rats-epoch-marker/issues/18

[^issue]: Issue tracked at:

The TST-info-based-on-CBOR-time-tag is semantically equivalent to classical
{{-TSA}} TSTInfo, rewritten using the CBOR type system.

~~~~ CDDL
{::include cddl/tst-info.cddl}
~~~~

The following describes each member of the TST-info-based-on-CBOR-time-tag map.

{:vspace}
version:
: The integer value 1.  Cf. version, {{Section 2.4.2 of -TSA}}.

policy:
: A {{-CBOR-OID}} object identifier tag (111 or 112) representing the TSA's
policy under which the tst-info was produced.  Cf. policy, {{Section 2.4.2 of
-TSA}}.

messageImprint:
: A {{-COSE-HASH-ALGS}} COSE_Hash_Find array carrying the hash algorithm
identifier and the hash value of the time-stamped datum.  Cf. messageImprint,
{{Section 2.4.2 of -TSA}}.

serialNumber:
: A unique integer value assigned by the TSA to each issued tst-info.  Cf.
serialNumber, {{Section 2.4.2 of -TSA}}.

eTime:
: The time at which the tst-info has been created by the TSA.  Cf. genTime,
{{Section 2.4.2 of -TSA}}.
Encoded as extended time {{-CBOR-ETIME}}, indicated by CBOR tag 1001, profiled
as follows:

- The "base time" is encoded using key 1, indicating Posix time as int or float.
- The stated "accuracy" is encoded using key -8, which indicates the maximum
  allowed deviation from the value indicated by "base time".  The duration map
  is profiled to disallow string keys.  This is an optional field.
- The map MAY also contain one or more integer keys, which may encode
  supplementary information [^tf1].

[^tf1]: Allowing unsigned integer (i.e., critical) keys goes counter interoperability

{:vspace}
ordering:
: boolean indicating whether tst-info issued by the TSA can be ordered solely
based on the "base time". This is an optional field, whose default value is
"false".  Cf. ordering, {{Section 2.4.2 of -TSA}}.

nonce:
: int value echoing the nonce supplied by the requestor.  Cf. nonce, {{Section
2.4.2 of -TSA}}.

tsa:
: a single-entry GeneralNames array {{Section 11.8 of -C509}} providing a hint
in identifying the name of the TSA.  Cf. tsa, {{Section 2.4.2 of -TSA}}.

$$TSTInfoExtensions:
: A CDDL socket ({{Section 3.9 of -CDDL}}) to allow extensibility of the data
format.  Note that any extensions appearing here MUST match an extension in the
corresponding request.  Cf. extensions, {{Section 2.4.2 of -TSA}}.


### Multi-Nonce {#sec-multi-nonce}

Typically, a nonce is a number only used once. In the context of Epoch Markers, one Nonce can be distributed to multiple consumers, each of them using that Nonce only once. Technically, that is not a Nonce anymore. This type of Nonce is called Multi-Nonce in Epoch Markers.

~~~~ CDDL
{::include cddl/multi-nonce.cddl}
~~~~

### Multi-Nonce-List {#sec-multi-nonce-list}

A list of nonces send to multiple consumers. The consumers use each Nonce in the list of Nonces sequentially. Technically, each sequential Nonce in the distributed list is not used just once, but by every Epoch Marker consumer involved. This renders each Nonce in the list a Multi-Nonce

~~~~ CDDL
{::include cddl/multi-nonce-list.cddl}
~~~~

### Strictly Monotonically Increasing Counter {#sec-strictly-monotonic}

A strictly monotonically increasing counter.

The counter context is defined by the Epoch bell.

~~~~ CDDL
{::include cddl/strictly-monotonic-counter.cddl}
~~~~

### Stateless Nonce {#sec-stateless-nonce}

In a highly available service (e.g., a cloud attestation verifier) having to
keep per-session nonce state poses scalablity problems.  An alternative is to
use time-synchronised servers that share a symmetric key, which produce and
consume nonces based on coarse-grained clock ticks that are signed using the
shared secret.  This way, a nonce minted by a server in the pool can be
processed by any other server in pool, which avoids the need for session
"stickiness."

A stateless-nonce supports the above use case by encoding a Posix time (i.e.,
the epoch identifier), alongside a minimal set of metadata, authenticated with
a symmetric key in a self-contained and compact token.

~~~~ CDDL
{::include cddl/stateless-nonce.cddl}
~~~~

The following describes each member of the stateless-nonce array:

{:vspace}

Version:
: version of the TimeToken encoded as a single byte.  The value MUST be 0x01.

KeyID:
: opaque identifier shared across the server pool for the signing key used to
compute AuthTag.  It is semantically equivalent to the TID field defined in
{{Section 3.1.3 of ?RFC6896}}.

Timestamp:
: the timestamp associated with the current epoch encoded as CBOR tag for Posix
time.  It MUST use the int format.

Pad:
: zero or more pad bytes, used to make the stateless nonce the desired size.

AuthTag:
: HMAC {{-HMAC}} w/ SHA-256 computed over the CBOR serialisation of TimeToken
encoded as a 32-bytes string.

# Security Considerations

TODO

# IANA Considerations {#sec-iana-cons}

[^rfced-replace]

[^rfced-replace]: RFC Editor: please replace {{&SELF}} with the RFC
    number of this RFC and remove this note.

## New CBOR Tags {#sec-iana-cbor-tags}

IANA is requested to allocate the following tags in the "CBOR Tags" registry
{{!IANA.cbor-tags}}, preferably with the specific CBOR tag value requested:

| Tag | Data Item | Semantics | Reference |
| -- | -- | -- | -- |
| 26980 | bytes | DER-encoded RFC3161 TSTInfo | {{sec-rfc3161-classic}} of {{&SELF}} |
| 26981 | map | CBOR-encoding of RFC3161 TSTInfo semantics | {{sec-rfc3161-fancy}} of {{&SELF}} |
| 26982 | tstr / bstr / int | a nonce that is shared among many participants but that can only be used once by each participant | {{sec-multi-nonce}} of {{&SELF}} |
| 26983 | array | a list of multi-nonce | {{sec-multi-nonce-list}} of {{&SELF}} |
| 26984 | uint | strictly monotonically increasing counter | {{sec-strictly-monotonic}} of {{&SELF}} |
| 26985 | array | stateless nonce | {{sec-stateless-nonce}} of {{&SELF}} |
{: #tbl-cbor-tags align="left" title="New CBOR Tags"}

--- back

# Examples {#examples}

The example in {{fig-ex-1}} shows an epoch marker with a cbor-epoch-id and no
bell veracity proof.

~~~~ CBOR-DIAG
{::include cddl/examples/1.diag}
~~~~
{: #fig-ex-1 artwork-align="center"
   title="CBOR epoch id without bell veracity proof"}

## RFC 3161 TSTInfo {#classic-tstinfo}

As a reference for the definition of TST-info-based-on-CBOR-time-tag the code block below depects the original layout of the TSTInfo structure from {{-TSA}}.

~~~~ ASN.1
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

# Acknowledgements
{:unnumbered}

TBD
