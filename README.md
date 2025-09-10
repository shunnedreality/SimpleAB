# SimpleAB
Simple is in the name, this is an extremely lightweight testing utility that helps you create up to 3 testing variants (Control, A, B). It automatically assigns a server-persistent variant to a given UserId. While you can use SimpleAB by itself to manage testing variants, you can also connect the given variant to Analytics Service to give more information for your testing.

**Wally: `shunnedreality/simpleab`**

## How does it work?
First, you start by creating a test.
```
--This is the name of your test.
local testName = "NewShopUI";

--[[
    This determines if some players are assigned a control variant.

    A control variant is typically the pre-existing variant to act as a
        baseline.
]]
local hasControl = true;

local Test = SimpleAB.createTest(testName, hasControl);
```

Then, you can use the Test API to get a variant assigned to a UserID.
This variant will be saved to DataStoreService for accurate testing.
```
local userID = 012345678;
local variant = Test:getUserData(userID);
```
This returns one of 3 values:
|Value | Variant label | 
|--- | --- |
|`-1` | `ControlVariant`. Only returns when enabled. |
|`0` | `VariantA` |
|`1` | `VariantB` |

Alternatively, to get the variant in string form (which is useful for analytics), you can simply call `SimpleAB:getVariantLabel(variant)`, which would return the corresponding label.

```
local variant = 0
print(Test:getVariantLabel(variant)) --Output: "VariantA"
```

## Using with Analytics
Simply pass the variant with the `customFields` property in any `AnalyticsService` log function.
```
AnalyticsService:LogCustomEvent(Player, "OpenShop", 1, {
    variant = Test:getUserData(...)
});
```
