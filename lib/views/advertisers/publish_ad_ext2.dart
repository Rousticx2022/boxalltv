part of 'publish_ad.dart';

extension _PublishAdStateExt2 on _PublishAdState {
  openZipcodeSheet() {
    Get.bottomSheet(
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(15, kToolbarHeight, 15, 0),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Get.back(),
                    child: Container(
                      margin: const EdgeInsets.only(right: 10),
                      padding: const EdgeInsets.all(4),
                      decoration: const ShapeDecoration(
                          color: Colors.white12, shape: CircleBorder()),
                      child: const Icon(Icons.close),
                    ),
                  ),
                  Text("Select Zipcode",
                      style: fontHeading(
                          fontSize: 20.sp, fontWeight: FontWeight.w600)),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(15, 20, 15, 0),
              child: TextFormField(
                controller: searchZipcodeController,
                style: customTextStyleBody(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: kWhiteColor),
                keyboardType: TextInputType.text,
                onChanged: (v) {
                  searchZipcode.value = v;
                },
                decoration: InputDecoration(
                  hintText: "Search zipcode...",
                  fillColor: Colors.white10,
                  filled: true,
                  isDense: true,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 25, vertical: 25),
                  hintStyle: customTextStyleBody(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: kWhiteColor),
                  prefixIcon: const Icon(Remix.search_2_fill, size: 20),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15)),
                  enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15)),
                  focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15)),
                ),
              ),
            ),
            Container(
              margin: const EdgeInsets.symmetric(vertical: 15),
              height: 40,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                scrollDirection: Axis.horizontal,
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  return Obx(
                    () => GestureDetector(
                      onTap: () {
                        selectedTargetCountry.value =
                            targetCountries[index]["country"];
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 15, vertical: 10),
                        decoration: ShapeDecoration(
                          color: selectedTargetCountry.value ==
                                  targetCountries[index]["country"]
                              ? null
                              : Colors.white10,
                          shape: const StadiumBorder(),
                          gradient: selectedTargetCountry.value ==
                                  targetCountries[index]["country"]
                              ? const LinearGradient(
                                  colors: [
                                    Color(0xffdb3445),
                                    Color(0xfff71735)
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                )
                              : null,
                        ),
                        child: Text(targetCountries[index]["country"],
                            style: fontPoppins()),
                      ),
                    ),
                  );
                },
                separatorBuilder: (context, i) => const SizedBox(width: 10),
                itemCount: targetCountries.length,
              ),
            ),
            Expanded(
              child: Obx(
                () => FirestoreListView(
                    query: targetZipcodesCollection
                        .where("country",
                            isEqualTo: selectedTargetCountry.value)
                        .orderBy("state"),
                    padding: const EdgeInsets.all(15),
                    itemBuilder: (context, zicode) {
                      return ListTile(
                        onTap: () {
                          if (selectedZipcodes.contains(zicode["zipcode"])) {
                            selectedZipcodes.remove(zicode["zipcode"]);
                          } else {
                            selectedZipcodes.add(zicode["zipcode"]);
                          }

                          zipcodesController.text = selectedZipcodes.join(",");
                        },
                        leading: Obx(() {
                          return Checkbox(
                            value: selectedZipcodes.contains(zicode["zipcode"]),
                            checkColor: kBlackColor,
                            onChanged: (v) {
                              if (selectedZipcodes
                                  .contains(zicode["zipcode"])) {
                                selectedZipcodes.remove(zicode["zipcode"]);
                              } else {
                                selectedZipcodes.add(zicode["zipcode"]);
                              }

                              zipcodesController.text =
                                  selectedZipcodes.join(",");
                            },
                          );
                        }),
                        minLeadingWidth: 0,
                        title: Text(zicode["city"], style: fontPoppins()),
                        subtitle: Text(zicode["zipcode"], style: fontPoppins()),
                        trailing: Text(zicode["state"], style: fontPoppins()),
                      );
                    }),
              ),
            ),
          ],
        ),
        isScrollControlled: true,
        barrierColor: Colors.white10,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
        backgroundColor: kBlackColor);
  }
}
