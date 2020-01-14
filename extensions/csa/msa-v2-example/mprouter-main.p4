/*
 * Author: Hardik Soni
 * Email: hks57@cornell.edu
 */

#include"msa.p4"
#include"common.p4"

struct meta_t { 
	bit<8> l4proto;
}

header ethernet_h {
  bit<48> dmac;
  bit<48> smac;
  bit<16> ethType; 
}

struct hdr_t {
  ethernet_h eth;
}

cpackage MPRouter : implements Unicast<hdr_t, meta_t, 
                                            empty_t, empty_t, empty_t> {
  parser micro_parser(extractor ex, pkt p, im_t im, out hdr_t hdr, inout meta_t m,
                        in empty_t ia, inout empty_t ioa) {
    state start {
      ex.extract(p, hdr.eth);
      transition accept;
    }
  }

  control micro_control(pkt p, im_t im, inout hdr_t hdr, inout meta_t m,
                          in empty_t ia, out empty_t oa, inout empty_t ioa) {
    bit<16> nh;
    L3v4() l3v4_i;
    L3v6() l3v6_i;
    Mpls() mpls_i;
    action forward(bit<48> dmac, bit<48> smac, PortId_t port) {
      hdr.eth.dmac = dmac;
      hdr.eth.smac = smac;
      im.set_out_port(port);
    }
    table forward_tbl {
      key = { nh : exact; } 
      actions = { forward; }
    }
    apply { 
      nh = 16w0;
      if (hdr.eth.ethType == 0x0800)
        l3v4_i.apply(p, im, ia, nh, ioa);
      else if (hdr.eth.ethType == 0x86DD)
        l3v6_i.apply(p, im, ia, nh, ioa);

      if (nh == 16w0)
        mpls_i.apply(p, im, nh, oa, hdr.eth.ethType);

      forward_tbl.apply(); 
    }
  }

  control micro_deparser(emitter em, pkt p, in hdr_t hdr) {
    apply { 
      em.emit(p, hdr.eth); 
    }
  }
}

MPRouter() main;


 
