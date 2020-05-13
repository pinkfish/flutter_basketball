import cors from "cors";
import * as functions from "firebase-functions";

export default functions.https.onRequest((req, res) => {
  console.log(req.body);
  console.log(req.params);
  const func = cors();
  return func(req, res, () => {
    console.log("cors success");
    res.status(200).send("Yay");
  });
});
