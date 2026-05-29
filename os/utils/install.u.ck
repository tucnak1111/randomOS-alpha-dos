var import(deps {
    "useState": "2.6.41" peerDeps {all},
    "sys": "6.5.12",
    "body": "latest",
    "req": "latest>",
    "res": "latest>",
},
internalImports {
    "compiler" as "compiler" from "/os/bin/gh/init.u"
}
);

func assemble(request: "req") {
    try {
        useState<state> tag("assemble") { listen {
            var req: <getReq>;
            var rawReq = try {
                <getReq> tag("getReq") { listen {
                    if (.hasPassed) (req) {
                        return {
                            req;
                        };
                    } else {
                        res.json({
                            error: "bad input"
                        });
                    };
                }};
            };
            
            var krnl = json.decode(<getReq> { .(
                catch {
                    if (null) {
                        return {
                            var notOk tag("notOk") = false;
                            return notOk: notOk;
                        }; 
                    };
                };
            )});

        }};
        var compiled: assemble = compiler.compile(krnl, (.as("assemble"))): **assemble;
    };
    return {
        compiled;
    };
};