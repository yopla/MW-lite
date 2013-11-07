/*
c2p.js :: connect coll to pattrstorage via javascript
store contents of a coll in a pattr-value array and dump it back
when pattr slots change
jasch 20081114
*/

// autowatch = 0;
inlets = 4;

// variable declarations
var warehouse = new Array();
var supplier = new Array();
var i = 0;
var j = 0;
var index = 0;
var count = 0;

// unique marker string
const marker = "#-#";

/* standard functions */

function bang()
{
if(inlet == 0) { // bang on first inlet :: new content
warehouse[index++] = "bang";
} else if(inlet == 1) { // bang on second inlet :: new keyword
warehouse[index++] = marker;
warehouse[index++] = "bang";
} else if(inlet == 2) { // bang on third inlet -> read finished : : get contents
outlet(0, "dump");
} else if(inlet == 3) { // bang on fourth inlet -> dump finished : : notify pattrwarehouse;
notifyclients();
}
}
bang.immediate = 1;

function msg_int(a)
{
if(inlet == 0) { // content
warehouse[index++] = a;
} else if(inlet == 1) { // index
warehouse[index++] = marker;
warehouse[index++] = a;
}
}

function msg_float(a)
{
if(inlet == 0) { // content
warehouse[index++] = a;
}
}
msg_int.immediate = 1;

function list()
{
if(inlet == 0) {
var b = arrayfromargs(arguments);
for(i = 0; i < b.length; i++){
warehouse[index++] = b[i];
}
}
}
list.immediate = 1;

function anything()
{
if(inlet == 0){
var a = arrayfromargs(messagename, arguments);
for(i = 0; i < a.length; i++){
warehouse[index++] = a[i];
}
}
}
anything.immediate = 1;

function symbol(s)
{
if(inlet == 0){
warehouse[index++] = s;
} else if(inlet == 1) {
warehouse[index++] = marker;
warehouse[index++] = s;
}
}
symbol.immediate = 1;

/* pattr communication */

/* when notified, pattr calls this function to retrieve the warehouse
array */
function getvalueof()
{
return warehouse;
}
getvalueof.local = 1;

/* pattr sends new values to array, we update coll */
function setvalueof()
{
warehouse.length = 0;
warehouse = arrayfromargs(arguments);
dump();
}
setvalueof.local = 1;

/* call this function BEFORE storing a pattr preset */
function store()
{
warehouse.length = 0;
index = 0;
notifyclients();
post(warehouse);
outlet(0, "dump");
}
store.immediate = 1;

/* call this function AFTER recalling a pattr preset */
function dump()
{
outlet(0, "clear"); // reset the client coll
supplier.length = 0;
count = 0;

for(i = 0; i < warehouse.length; i++) {
if(warehouse[i] == marker) {
if(supplier.length > 0) {
if(supplier.length > 1) {
if(typeof(supplier[0]) == "number") {
supplier[0] = supplier[0].toFixed(0);
}
outlet(0, "store", supplier); // supply the entry to coll
}
supplier.length = 0;
count = 0;
}
} else {
supplier[count] = warehouse[i];
count++;
}
}
if(supplier.length > 1) {
if(typeof(supplier[0]) == "number") {
supplier[0] = supplier[0].toFixed(0);
}
outlet(0, "store", supplier); // supply the entry to coll
}

}
dump.immediate = 1;

function clear()
{
warehouse.length = supply.length = count = index = 0;
}
clear.immediate = 1;