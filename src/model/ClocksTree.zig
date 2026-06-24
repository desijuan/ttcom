const std = @import("std");
const ArrayList = std.ArrayList;

const mem = @import("../mem.zig");

const Conn = @import("db/Conn.zig");

const Org = @import("db/Org.zig");
const Building = @import("db/Building.zig");
const Clock = @import("db/Clock.zig");

const BuildingBranch = struct {
    building: Building,
    clocks: []const Clock,
};

const OrgBranch = struct {
    org: Org,
    b_building: []const BuildingBranch,
};

const ClocksTree = @This();

b_orgs: []const OrgBranch,

pub fn deinit(self: ClocksTree) void {
    for (self.b_orgs) |b_org| {
        for (b_org.b_building) |b_building| {
            for (b_building.clocks) |clock| clock.deinit();

            mem.a.free(b_building.clocks);
            b_building.building.deinit();
        }

        mem.a.free(b_org.b_building);
        b_org.org.deinit();
    }

    mem.a.free(self.b_orgs);
}

pub const ReadError = error{ OutOfMemory, PrepareFailed, BindFailed, StepFailed, CastFailed };

pub fn read(conn: Conn) ReadError!ClocksTree {
    const orgs: []const Org = try Org.getAll(conn);
    defer mem.a.free(orgs);

    var list_b_orgs: ArrayList(OrgBranch) = try .initCapacity(mem.a, 16);
    errdefer list_b_orgs.deinit(mem.a);

    for (orgs) |org| {
        const buildings: []const Building = try Building.findByOrgId(org.id, conn);
        defer mem.a.free(buildings);

        var list_b_build: ArrayList(BuildingBranch) = try .initCapacity(mem.a, 16);
        errdefer list_b_build.deinit(mem.a);

        for (buildings) |building| {
            const clocks: []const Clock = try Clock.findByBuildingId(building.id, conn);

            try list_b_build.append(mem.a, BuildingBranch{
                .building = building,
                .clocks = clocks,
            });
        }

        try list_b_orgs.append(mem.a, OrgBranch{
            .org = org,
            .b_building = try list_b_build.toOwnedSlice(mem.a),
        });
    }

    return ClocksTree{ .b_orgs = try list_b_orgs.toOwnedSlice(mem.a) };
}
