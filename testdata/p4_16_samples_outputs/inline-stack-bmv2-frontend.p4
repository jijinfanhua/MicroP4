#include <core.p4>
#include <v1model.p4>

typedef standard_metadata_t std_meta_t;
header h_t {
    bit<1> f;
}

struct H {
    h_t[1] stack;
}

struct M {
}

parser ParserI(packet_in pk, out H hdr, inout M meta, inout std_meta_t std_meta) {
    state start {
        transition accept;
    }
}

control VerifyChecksumI(inout H hdr, inout M meta) {
    apply {
    }
}

control ComputeChecksumI(inout H hdr, inout M meta) {
    apply {
    }
}

control Aux(inout H hdr) {
    apply {
    }
}

control IngressI(inout H hdr, inout M meta, inout std_meta_t std_meta) {
    @name("aux") Aux() aux_0;
    apply {
        aux_0.apply(hdr);
        aux_0.apply(hdr);
    }
}

control EgressI(inout H hdr, inout M meta, inout std_meta_t std_meta) {
    apply {
    }
}

control DeparserI(packet_out b, in H hdr) {
    apply {
    }
}

V1Switch<H, M>(ParserI(), VerifyChecksumI(), IngressI(), EgressI(), ComputeChecksumI(), DeparserI()) main;

